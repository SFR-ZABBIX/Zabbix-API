package Zabbix::API::Host;

use strict;
use warnings;
use 5.010;
use Carp;

sub new {

    my ($class, %args) = @_;

    my $self = \%args;

    bless $self, $class;

    my @missing = $self->_validate;

    @missing and croak "$class->new is missing parameters: @missing\n";

    return $self;

}

sub _validate {

    my $self = shift;

    my @required = qw/_root port ip status hostid error macros host/;

    my @missing;

    foreach (@required) {

        push @missing, ($_) unless exists $self->{$_};

    }

    foreach (keys %{$self}) {

        delete $self->{$_} unless $_ ~~ @required;

    }

    return @missing;

}
1;
__END__
=pod

=head1 NAME

Zabbix::Host -- Base class for Zabbix hosts

=head1 SYNOPSIS

  use Zabbix;

  my $zabbix = Zabbix->new(...);

  my $host = $zabbix->get_hosts(hostnames => ['Zabbix Server'])->[0];

=head1 DESCRIPTION

This class doesn't do much beyond blessing a hashref of data (provided by the
Zabbix API).

=head1 ATTRIBUTES

None.

=head1 METHODS

=over 4

=item new(%params)

This is the main constructor for the Zabbix::Host class.  The following
parameters are required at present: _root port ip status hostid error macros
host.

All these can be fetched through the API with the C<host.get> JSON-RPC method,
although the Zabbix C<get_hosts> method or the Zabbix::Item C<get_host> method
are more convenient (they also return Zabbix::Host instances rather than raw
hashrefs).

The constructor filters the parameters hash so that only the required keys are
present before the blessed ref is returned.  An exception will be thrown if
one or more required keys are missing:

  "$class->new is missing parameters: ..."

=back

=head1 SEE ALSO

L<Zabbix>

The Zabbix API documentation, at L<http://www.zabbix.com/documentation/start>

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fabrice Gabolde

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.10.0 or, at your option,
any later version of Perl 5 you may have available.

=cut
