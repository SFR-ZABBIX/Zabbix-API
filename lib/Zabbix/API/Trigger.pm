package Zabbix::API::Trigger;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{triggerid} = $value;
        return $self->data->{triggerid};

    } else {

        return $self->data->{triggerid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'trigger'.$suffix;

    } else {

        return 'trigger';

    }

}

sub extension {

    return ( output => 'extend',
             select_hosts => 'refer',
             select_items => 'refer',
             select_dependencies => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { description => [ $self->data->{description} ] },
                                              $self->extension })};

}

sub name {

    my $self = shift;

    # can't think of a good name for triggers -- descriptions are too long
    return $self->data->{description};

}

sub hosts {

    ## accessor for host

    my ($self, $value) = @_;

    if (defined $value) {

        croak 'Accessor hosts called as mutator';

    } else {

        unless (exists $self->{hosts}) {

            $self->{hosts} = $self->{root}->fetch('Host', params => { hostids => [ map { $_->{hostid} } @{$self->data->{hosts}} ] });

        }

        return $self->{hosts};

    }

}

sub items {

    ## accessor for host

    my ($self, $value) = @_;

    if (defined $value) {

        croak 'Accessor items called as mutator';

    } else {

        unless (exists $self->{items}) {

            $self->{items} = $self->{root}->fetch('Item', params => { itemids => [ map { $_->{itemid} } @{$self->data->{items}} ] });

        }

        return $self->{items};

    }

}

sub pull {

    # override CRUDE's pull

    my ($self, @args) = @_;

    # because they might have been updated
    delete $self->{hosts};
    delete $self->{items};

    # and now this will set the correct ids, and next time we access the hosts
    # or items they will be up to date
    $self->SUPER::pull(@args);

    return $self;

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Trigger -- Zabbix trigger objects

=head1 SYNOPSIS

  use Zabbix::API::Trigger;

  # TODO write the rest

=head1 DESCRIPTION

TODO write this

=head1 ATTRIBUTES

=over 4

=item attribute1

TODO write this

=item attribute2

TODO write this

=back

=head1 METHODS

=over 4

=item method(args)

TODO write this

=back

=head1 SEE ALSO

TODO links to other pods and documentation

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Devoteam

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
