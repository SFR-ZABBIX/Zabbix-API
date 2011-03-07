package Zabbix;

use strict;
use warnings;
use 5.010;

use Params::Validate qw/:all/;
use Carp;
use Data::Dumper;

use parent 'Exporter';
our @EXPORT = qw/zabbix_get/;
our @EXPORT_OK = qw/zabbix_auth_cookie/;

use JSON;
use LWP::UserAgent;

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

sub get_item_from_host {

    my $self = shift;

    my %args = validate(@_, { host => { TYPE => SCALAR },
                              key => { TYPE => SCALAR } });

    return $self->get(method => 'item.get',
                      params => {
                          filter => { host => $args{'host'},
                                      key_ => $args{'key'} },
                          output => 'extend',
                      });

}

1;
__END__
=pod

=head1 NAME

Zabbix -- Access the JSON-RPC API of a Zabbix server

=head1 SYNOPSIS

  use Zabbix;

  my $zabbix = Zabbix->new(server => 'http://example.com/zabbix/api_jsonrpc.php',
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

This is the main constructor for the Zabbix class.  It creates a
LWP::UserAgent instance but does B<not> open any connections yet.

Returns an instance of the C<Zabbix> class.

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

=item get_item_from_host(host => ZABBIX_HOST, key => STR)

Wrapper around C<get>.  This method is shorthand for:

  return $self->get(method => 'item.get',
                    params => {
                        host => HOST,
                          search => { key_ => KEY },
                          filter => FIELDS,
                          output => 'extend',
                    });

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
