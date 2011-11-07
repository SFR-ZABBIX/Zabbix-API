package Zabbix::API::Host;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{hostid} = $value;
        return $self->data->{hostid};

    } else {

        return $self->data->{hostid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'host'.$suffix;

    } else {

        return 'host';

    }

}

sub extension {

    return ( output => 'extend',
             select_macros => 'extend',
             select_groups => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { host => $self->data->{host} },
                                              $self->extension })};

}

sub name {

    my $self = shift;

    return $self->data->{host} || '???';

}

sub items {

    ## accessor for items

    my ($self, $value) = @_;

    if (defined $value) {

        die 'Accessor items called as mutator';

    } else {

        my $items = $self->{root}->fetch('Item', params => { hostids => [ $self->data->{hostid} ] });

        $self->{items} = $items;

        return $self->{items};

    }

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Host -- Zabbix host objects

=head1 SYNOPSIS

  use Zabbix::API::Host;

  # fetch a single host by ID
  my $host = $zabbix->fetch('Host', params => { filter => { hostid => 10105 } });

  # and delete it
  $host->delete;

=head1 DESCRIPTION

Handles CRUD for Zabbix host objects.

This is a subclass of C<Zabbix::API::CRUDE>; see there for inherited methods.

=head1 METHODS

=over 4

=item items()

Accessor for the host's items.

=back

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 SFR

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
