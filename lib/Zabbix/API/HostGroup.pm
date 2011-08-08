package Zabbix::API::HostGroup;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{groupid} = $value;
        return $self->data->{groupid};

    } else {

        return $self->data->{groupid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'hostgroup'.$suffix;

    } else {

        return 'hostgroup';

    }

}

sub extension {

    return ( output => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { name => $self->data->{name} },
                                              $self->extension })};

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::HostGroup -- Zabbix group objects

=head1 SYNOPSIS

  use Zabbix::API::HostGroup;

  my $group = $zabbix->fetch(...);

  $group->delete;

=head1 DESCRIPTION

Handles CRUD for Zabbix group objects.

This is a very simple subclass of C<Zabbix::API::CRUDE>.  Only the required
methods are implemented (and in a very simple fashion on top of that).

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
