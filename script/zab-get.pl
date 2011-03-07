#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Zabbix;
use Data::Dumper;
use Getopt::Long::Descriptive;

use DateTime;

my ($opt, $usage) = describe_options(
    'zab-get.pl %o',
    [ 'server=s', 'Zabbix server to connect to', { required => 1 } ],
    [ 'verbose|v+', 'verbosity level' ],
    [ 'help|h', 'this usage screen' ],);

say $usage and exit if $opt->help;

my $zabber = Zabbix->new(server => $opt->server,
                         verbosity => $opt->verbose // 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

die 'no cookie :(' unless $zabber->has_cookie;

my $items = $zabber->get_item_from_host(host => 'Zabbix Server',
                                        key => 'system.uptime');

print Dumper($items);
