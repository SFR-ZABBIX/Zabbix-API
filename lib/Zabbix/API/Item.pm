package Zabbix::API::Item;

use strict;
use warnings;
use 5.010;
use Carp qw/confess/;

sub new {

    my ($class, %args) = @_;

    my $self = \%args;

    bless $self, $class;

    my @missing = $self->_validate;

    @missing and confess "$class->new is missing parameters: @missing\n";

    return $self;

}

sub _validate {

    my $self = shift;

    my @required = qw/_root data_type formula key_ description params lastvalue status error hostid itemid units/;

    my @missing;

    foreach (@required) {

        push @missing, ($_) unless exists $self->{$_};

    }

    foreach (keys %{$self}) {

        delete $self->{$_} unless $_ ~~ @required;

    }

    return @missing;

}

sub get_host {

    my $self = shift;

    return $self->{_root}->get_hosts(hostids => [ $self->{hostid} ])->[0];

}

1;
__END__
=pod

=head1 NAME

Zabbix::Item -- Base class for Zabbix items

=head1 SYNOPSIS

  use Zabbix;

  my $zabbix = Zabbix->new(...);

  my $items = $zabbix->get_items(key => 'system.uptime');

=head1 DESCRIPTION

This class doesn't do much beyond blessing a hashref of data (provided by the
Zabbix API).

=head1 ATTRIBUTES

None.

=head1 METHODS

=over 4

=item new(%params)

This is the main constructor for the Zabbix::Item class.  The following
parameters are required at present: _root data_type formula key_ description
params lastvalue status error hostid itemid units.

All these can be fetched through the API with the C<item.get> JSON-RPC method,
although the Zabbix C<get_items> method is more convenient (it also returns
Zabbix::Item instances rather than raw hashrefs).

The constructor filters the parameters hash so that only the required keys are
present before the blessed ref is returned.  An exception will be thrown if
one or more required keys are missing:

  "$class->new is missing parameters: ..."

=item get_host

Return the item's host.  Behind the scenes, this calls the Zabbix root
instance to perform a C<get_host> call.  Future versions may cache some data
to improve performance.

=back

=head1 SEE ALSO

L<Zabbix>, L<Zabbix::Host>

The Zabbix API documentation, at L<http://www.zabbix.com/documentation/start>

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fabrice Gabolde

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.10.0 or, at your option,
any later version of Perl 5 you may have available.

=cut
