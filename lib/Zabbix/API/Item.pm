package Zabbix::API::Item;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Exporter Zabbix::API::CRUDE/;

use constant {
    ITEM_TYPE_ZABBIX => 0,
    ITEM_TYPE_SNMPV1 => 1,
    ITEM_TYPE_TRAPPER => 2,
    ITEM_TYPE_SIMPLE => 3,
    ITEM_TYPE_SNMPV2C => 4,
    ITEM_TYPE_INTERNAL => 5,
    ITEM_TYPE_SNMPV3 => 6,
    ITEM_TYPE_ZABBIX_ACTIVE => 7,
    ITEM_TYPE_AGGREGATE => 8,
    ITEM_TYPE_HTTPTEST => 9,
    ITEM_TYPE_EXTERNAL => 10,
    ITEM_TYPE_DB_MONITOR => 11,
    ITEM_TYPE_IPMI => 12,
    ITEM_TYPE_SSH => 13,
    ITEM_TYPE_TELNET => 14,
    ITEM_TYPE_CALCULATED => 15,
    ITEM_VALUE_TYPE_FLOAT => 0,
    ITEM_VALUE_TYPE_STR => 1,
    ITEM_VALUE_TYPE_LOG => 2,
    ITEM_VALUE_TYPE_UINT64 => 3,
    ITEM_VALUE_TYPE_TEXT => 4,
    ITEM_DATA_TYPE_DECIMAL => 0,
    ITEM_DATA_TYPE_OCTAL => 1,
    ITEM_DATA_TYPE_HEXADECIMAL => 2,
    ITEM_STATUS_ACTIVE => 0,
    ITEM_STATUS_DISABLED => 1,
    ITEM_STATUS_NOTSUPPORTED => 3
};

our @EXPORT_OK = qw/
ITEM_TYPE_ZABBIX
ITEM_TYPE_SNMPV1
ITEM_TYPE_TRAPPER
ITEM_TYPE_SIMPLE
ITEM_TYPE_SNMPV2C
ITEM_TYPE_INTERNAL
ITEM_TYPE_SNMPV3
ITEM_TYPE_ZABBIX_ACTIVE
ITEM_TYPE_AGGREGATE
ITEM_TYPE_HTTPTEST
ITEM_TYPE_EXTERNAL
ITEM_TYPE_DB_MONITOR
ITEM_TYPE_IPMI
ITEM_TYPE_SSH
ITEM_TYPE_TELNET
ITEM_TYPE_CALCULATED
ITEM_VALUE_TYPE_FLOAT
ITEM_VALUE_TYPE_STR
ITEM_VALUE_TYPE_LOG
ITEM_VALUE_TYPE_UINT64
ITEM_VALUE_TYPE_TEXT
ITEM_DATA_TYPE_DECIMAL
ITEM_DATA_TYPE_OCTAL
ITEM_DATA_TYPE_HEXADECIMAL
ITEM_STATUS_ACTIVE
ITEM_STATUS_DISABLED
ITEM_STATUS_NOTSUPPORTED/;

our %EXPORT_TAGS = (
    item_types => [
        qw/ITEM_TYPE_ZABBIX
        ITEM_TYPE_SNMPV1
        ITEM_TYPE_TRAPPER
        ITEM_TYPE_SIMPLE
        ITEM_TYPE_SNMPV2C
        ITEM_TYPE_INTERNAL
        ITEM_TYPE_SNMPV3
        ITEM_TYPE_ZABBIX_ACTIVE
        ITEM_TYPE_AGGREGATE
        ITEM_TYPE_HTTPTEST
        ITEM_TYPE_EXTERNAL
        ITEM_TYPE_DB_MONITOR
        ITEM_TYPE_IPMI
        ITEM_TYPE_SSH
        ITEM_TYPE_TELNET
        ITEM_TYPE_CALCULATED/
    ],
    value_types => [
        qw/ITEM_VALUE_TYPE_FLOAT
        ITEM_VALUE_TYPE_STR
        ITEM_VALUE_TYPE_LOG
        ITEM_VALUE_TYPE_UINT64
        ITEM_VALUE_TYPE_TEXT/
    ],
    data_types => [
        qw/ITEM_DATA_TYPE_DECIMAL
        ITEM_DATA_TYPE_OCTAL
        ITEM_DATA_TYPE_HEXADECIMAL/
    ],
    status_types => [
        qw/ITEM_STATUS_ACTIVE
        ITEM_STATUS_DISABLED
        ITEM_STATUS_NOTSUPPORTED/
    ]
);

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{itemid} = $value;
        return $self->data->{itemid};

    } else {

        return $self->data->{itemid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'item'.$suffix;

    } else {

        return 'item';

    }

}

sub extension {

    return ( output => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { search => { key_ => $self->data->{key_} },
                                              hostids => [ $self->host->id ]})};

}

sub host {

    ## accessor for host

    my ($self, $value) = @_;

    if (defined $value) {

        croak 'Accessor host called as mutator';

    } else {

        unless (exists $self->{host}) {

            my $hosts = $self->{root}->fetch('Host', params => { hostids => [ $self->data->{hostid} ] });

            croak 'Unexpectedly found more than one host for a given item'
                if @{$hosts} > 1;

            $self->{host} = $hosts->[0];

        }

        return $self->{host};

    }

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

Handles CRUD for Zabbix item objects.

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
