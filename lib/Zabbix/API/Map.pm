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

Zabbix::API::Map -- Zabbix map objects

=head1 SYNOPSIS

  use Zabbix::API::Map;

  # TODO write the rest

=head1 DESCRIPTION

Handles CRUD for Zabbix map objects.

This is a very simple subclass of C<Zabbix::API::CRUDE>.  Only the required
methods are implemented (and in a very simple fashion on top of that).

=head1 EXPORTS

The various integers representing map element types are implemented as constants:

  MAP_ELEMENT_TYPE_HOST
  MAP_ELEMENT_TYPE_MAP
  MAP_ELEMENT_TYPE_TRIGGER
  MAP_ELEMENT_TYPE_HOSTGROUP
  MAP_ELEMENT_TYPE_IMAGE

Nothing is exported by default; you can use the tag C<:map_element_types> (or
import by name).

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
