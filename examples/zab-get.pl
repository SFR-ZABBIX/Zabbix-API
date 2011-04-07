#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Zabbix::API;
use Zabbix::API::Utils qw/RE_FORMULA/;
use Data::Dumper;
use Getopt::Long::Descriptive;
use DateTime;

my ($opt, $usage) = describe_options(
    'zab-get.pl %o',
    [ 'server=s', 'Zabbix server to connect to' ],
    [ 'verbose|v+', 'verbosity level' ],
    [ 'help|h', 'this usage screen' ],);

say $usage and exit if $opt->help;

my $zabber = Zabbix::API->new(server => $opt->server,
                              verbosity => $opt->verbose // 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

die 'no cookie :(' unless $zabber->has_cookie;

my $items = $zabber->get_items(host => 'Zabbix Server',
                               key => 'thing');

foreach my $item (@{$items}) {

    say "Got matching item for key 'thing'";

    if ($item->{error}) {

        say 'Error: '.$item->{error};

    } else {

        say 'Current value: '.$item->{lastvalue};
        say 'Parameters: '.$item->{params};

        print Dumper($item);

        my @hosts;

        my $re = RE_FORMULA;

        while ($item->{params} =~ m/$re/g) {

            my ($host, $item_arg) = @+{'host', 'item_arg'};

            say sprintf(q{Matched host '%s', args '%s'}, $host, $item_arg);

            push @hosts, ($host);

        }

        my $hosts = $zabber->get_hosts(hostnames => \@hosts);

        foreach my $host (@{$hosts}) {

            my $ip = $host->{ip};
            my $hostname = $host->{host};
            my $cap = { map { $_->{macro} => $_->{value} } @{$host->{macros}} };

            say "Found host '$hostname', IP is '$ip'";

            print Dumper($cap) if %{$cap};

        }

    }

}
