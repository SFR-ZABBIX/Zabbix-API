package Zabbix::Host;

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

  use Zabbix::Host;

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

Copyright (C) 2010 by Fabrice Gabolde

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.10.0 or, at your option,
any later version of Perl 5 you may have available.

=cut
