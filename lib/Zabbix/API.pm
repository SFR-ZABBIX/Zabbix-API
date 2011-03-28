package Zabbix::API;

use strict;
use warnings;
use 5.010;

use Params::Validate qw/:all/;
use Carp;
use Data::Dumper;
use Scalar::Util qw/weaken/;

use JSON;
use LWP::UserAgent;

use Zabbix::API::Item;
use Zabbix::API::Host;

sub new {

    my $class = shift;
    my %args = validate(@_, { server => 1,
                              verbosity => 0, });

    my $self = \%args;

    # defaults
    $self->{verbosity} = 0 unless exists $self->{verbosity};

    $self->{ua} = LWP::UserAgent->new(agent => 'Zabbix API client (libwww-perl)',
                                      from => 'fabrice.gabolde@uperto.com',
                                      show_progress => $self->{verbosity});

    $self->{cookie} = '';

    bless $self, $class;

    return $self;

}

sub has_cookie {

    my $self = shift;

    return $self->{cookie};

}

sub authenticate {

    my $self = shift;

    my %args = validate(@_, { user => 1,
                              password => 1 });

    my $response = $self->query(method => 'user.authenticate',
                                params => \%args);

    $self->{cookie} = '';
    $self->{cookie} = decode_json($response->decoded_content)->{result}
      if $response->is_success;

    return $self;

}

sub query {

    my ($self, %args) = @_;

    state $global_id = int(rand(10000));

    # common parameters
    $args{'jsonrpc'} = '2.0';
    $args{'auth'} = $self->{cookie} if $self->has_cookie;
    $args{'id'} = $global_id++;

    my $response = $self->{ua}->post($self->{server},
                                     'Content-Type' => 'application/json-rpc',
                                     Content => encode_json(\%args));

    given ($self->{verbosity}) {

        when (1) {

            print $response->as_string;

        }

        when (2) {

            print Dumper($response);

        }

        default {

        }

    }

    return $response;

}

sub get {

    my $self = shift;

    my %args = validate(@_, { method => { TYPE => SCALAR },
                              params => { TYPE => HASHREF,
                                          optional => 1 }});

    my $response = $self->query(%args);

    if ($response->is_success) {

        return decode_json($response->decoded_content)->{'result'};

    }

    return 0;

}

sub api_version {

    my $self = shift;

    my $response = $self->get(method => 'apiinfo.version');

    return $response;

}

sub get_items {

    my $self = shift;

    my %args = validate(@_, { host => { TYPE => SCALAR,
                                        optional => 1 },
                              hostids => { TYPE => ARRAYREF,
                                           optional => 1 },
                              key => { TYPE => SCALAR } });

    my $items;

    if (exists $args{'host'} and not exists $args{'hostids'}) {

        $items = $self->get(method => 'item.get',
                            params => {
                                filter => { host => $args{'host'},
                                            key_ => $args{'key'} },
                                output => 'extend',
                            });

    } elsif (exists $args{'hostids'} and not exists $args{'host'}) {

        $items = $self->get(method => 'item.get',
                            params => {
                                filter => { key_ => $args{'key'} },
                                hostids => [ map { $_ } @{$args{'hostids'}} ],
                                select_hosts => 'extend',
                                output => 'extend',
                            });

    } else {

        croak q{Exactly one of 'host' or 'hostids' must be specified as a parameter to get_items};

    }

    my $weak_ref_to_self = $self;
    weaken $weak_ref_to_self;

    return [ map { Zabbix::API::Item->new(_root => $weak_ref_to_self, %{$_}) } @{$items} ];

}

sub get_hosts {

    my $self = shift;

    my %args = validate(@_, { hostnames => { TYPE => ARRAYREF,
                                             optional => 1 },
                              hostids => { TYPE => ARRAYREF,
                                           optional => 1 } });

    my $hosts;

    if (exists $args{'hostnames'} and not exists $args{'hostids'}) {

        $hosts = $self->get(method => 'host.get',
                            params => { filter => { host => $args{'hostnames'} },
                                        output => 'extend',
                                        select_macros => 'extend' });

    } elsif (exists $args{'hostids'} and not exists $args{'hostnames'}) {

        $hosts = $self->get(method => 'host.get',
                            params => { hostids => $args{'hostids'},
                                        output => 'extend',
                                        select_macros => 'extend' });

    } else {

        croak q{Exactly one of 'hostnames' or 'hostids' must be specified as a parameter to get_items};

    }
    
    my $weak_ref_to_self = $self;
    weaken $weak_ref_to_self;

    return [ map { Zabbix::API::Host->new(_root => $weak_ref_to_self, %{$_}) } @{$hosts} ];

}

1;
__END__
=pod

=head1 NAME

Zabbix::API -- Access the JSON-RPC API of a Zabbix server

=head1 SYNOPSIS

  use Zabbix::API;

  my $zabbix = Zabbix::API->new(server => 'http://example.com/zabbix/api_jsonrpc.php',
                                verbosity => 0);

  $zabbix->authenticate(user => 'calvin',
                        password => 'hobbes');

  die 'could not authenticate' unless $zabbix->has_cookie;

  my $things = $zabber->get(method => 'apiinfo.version');

=head1 DESCRIPTION

This module manages authentication and querying to a Zabbix server via its
JSON-RPC interface.  (Zabbix v1.8+ is required for API usage; prior versions
have no JSON-RPC API at all.)

=head1 METHODS

=over 4

=item new(server => URL, [verbosity => INT])

This is the main constructor for the Zabbix::API class.  It creates a
LWP::UserAgent instance but does B<not> open any connections yet.

Returns an instance of the C<Zabbix::API> class.

=item authenticate(user => STR, password => STR)

Send login information to the Zabbix server and set the auth cookie if the
authentication was successful.

=item has_cookie

Return the current value of the auth cookie, which is a true value if the last
authentication was successful, or the empty string otherwise.

=item query(method => STR, [params => HASHREF])

Send a JSON-RPC query to the Zabbix server.  The C<params> hashref should
contain the method's parameters; query parameters (query ID, auth cookie,
JSON-RPC version, and HTTP request headers) are set by the method itself.

Return a C<HTTP::Response> object.

If the verbosity is set to 1, will print the C<HTTP::Response> to STDOUT.  If
set to 2, will print the Data::Dumper output of same (it also contains the
C<HTTP::Request> being replied to).

If the verbosity is strictly greater than 0, the internal LWP::UserAgent
instance will also print HTTP request progress.

=item get(method => STR, [params => HASHREF])

Wrapper around C<query> that will return the result data instead.

=back

The following methods are wrappers around C<get> that mostly curry out the
C<params> argument.

=over 4

=item api_version

Query the Zabbix server for the API version number and return it.

=item get_items(key => STR, [host => ZABBIX_HOST], [hostids => ARRAYREF])

Return an arrayref of hashrefs of data from Zabbix items.

The host-name-style (with C<host>) fetches data for a single host (the API
doesn't support filtering by more than one host by name; maybe we will later,
through a cache of hostid => hostname, or by calling C<get_hosts> behind the
scenes, which would be very slow.)

The hostids-style (with C<hostids>) fetches data for multiple hosts (the API
B<does> support filtering by more than one host by IDs).

Exactly one of C<host> and C<hostids> must be specified.

=item get_hosts(hostnames => ARRAYREF)

Return an arrayref of hashrefs of data from Zabbix hosts.

=back

=head1 LOW-LEVEL ACCESS

Several attributes are available if you want to dig into the class' internals,
through the standard blessed-hash-as-an-instance mechanism.  Those are:

=over 4

=item server

A string containing the URL to which JSON-RPC queries should be POSTed.

=item verbosity

Verbosity level.  So far levels 0 to 2 are supported (i.e. do something
different).

=item cookie

A string containing the current session's auth cookie, or the empty string if
unauthenticated.

=item ua

The LWP::UserAgent object that handles HTTP queries and responses.  This is
probably the most interesting attribute since several useful options can be
set: timeout, redirects, etc.

=back

=head1 SEE ALSO

The Zabbix API documentation, at L<http://www.zabbix.com/documentation/start>

L<LWP::UserAgent>

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fabrice Gabolde

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.10.0 or, at your option,
any later version of Perl 5 you may have available.

=cut
