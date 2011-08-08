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
             select_macros => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { host => $self->data->{host} },
                                              $self->extension })};

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Host -- Zabbix host objects

=head1 SYNOPSIS

  use Zabbix::API::Host;

  my $host = $zabbix->fetch(...);

  $host->delete;

=head1 DESCRIPTION

Handles CRUD for Zabbix host objects.

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
