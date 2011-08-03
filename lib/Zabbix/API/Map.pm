package Zabbix::API::Map;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Exporter Zabbix::API::CRUDE/;

# these do not exist in Zabbix but we make them up for consistency's sake
use constant {
    MAP_ELEMENT_TYPE_HOST => 0,
    MAP_ELEMENT_TYPE_MAP => 1,
    MAP_ELEMENT_TYPE_TRIGGER => 2,
    MAP_ELEMENT_TYPE_HOSTGROUP => 3,
    MAP_ELEMENT_TYPE_IMAGE => 4
};

our @EXPORT_OK = qw/
MAP_ELEMENT_TYPE_HOST
MAP_ELEMENT_TYPE_MAP
MAP_ELEMENT_TYPE_TRIGGER
MAP_ELEMENT_TYPE_HOSTGROUP
MAP_ELEMENT_TYPE_IMAGE/;

our %EXPORT_TAGS = (
    map_element_types => [
        qw/MAP_ELEMENT_TYPE_HOST
        MAP_ELEMENT_TYPE_MAP
        MAP_ELEMENT_TYPE_TRIGGER
        MAP_ELEMENT_TYPE_HOSTGROUP
        MAP_ELEMENT_TYPE_IMAGE/
    ],
);

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{sysmapid} = $value;
        return $self->data->{sysmapid};

    } else {

        return $self->data->{sysmapid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'map'.$suffix;

    } else {

        return 'map';

    }

}

sub extension {

    return ( output => 'extend',
             select_selements => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { search => { name => $self->data->{name} }})};

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Item -- Zabbix item objects

=head1 SYNOPSIS

  use Zabbix::API::Item;

  # TODO write the rest

=head1 DESCRIPTION

Handles CRUD for Zabbix graph objects.

This is a subclass of C<Zabbix::API::CRUDE>.

=head1 METHODS

=over 4

=item collides()

Returns true if the item exists with this key on this hostid, false otherwise.

=item host()

Accessor for a local C<host> attribute, which it also happens to set from the
server data if it isn't set already.

=back

=head1 EXPORTS

Way too many constants, but for once they're documented (here:
L<http://www.zabbix.com/documentation/1.8/api/item/constants>).

Nothing is exported by default; you can use the tags C<:item_types>,
C<:value_types>, C<:data_types> and C<:status_types> (or import by name).

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 SFR

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.10.0 or, at your option,
any later version of Perl 5 you may have available.

=cut
