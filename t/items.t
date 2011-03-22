use Test::More;
use Test::Exception;

if ($ENV{ZABBIX_SERVER}) {

    plan tests => 6;

} else {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok('Zabbix::API');

my $zabber = Zabbix::API->new(server => $ENV{ZABBIX_SERVER},
                              verbosity => 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

$zabber->has_cookie or BAIL_OUT('Could not authenticate, something is wrong!');

my $items = $zabber->get_items(host => 'Zabbix Server',
                               key => 'system.uptime');

is(@{$items}, 1, '... and we can fetch item data from a single host with named-host-style invocation');

my $zabbix_uptime = $items->[0];

isa_ok($zabbix_uptime, 'Zabbix::API::Item',
       '... and the object returned');

my $hosts = $zabber->get_hosts(hostnames => ['Zabbix Server', 'Zibbax Server']);

$items = $zabber->get_items(hostids => [ map { $_->{hostid} } @{$hosts} ],
                            key => 'net.if.in[eth0,bytes]');

is(@{$items}, 2, '... and we can fetch item data from multiple hosts with hostid-style invocation');

throws_ok(sub { $zabber->get_items(hostids => [ 1, 2 ],
                                   host => 'foo',
                                   key => 'system.uptime') },
          qr/^Exactly one of 'host' or 'hostids' must be specified as a parameter to get_items/,
          q{... and specifying both 'host' and 'hostids' ends in error});

use Data::Dumper;

my $host_from_item = $zabbix_uptime->get_host;
my ($host_directly) = grep { $_->{host} eq 'Zabbix Server' } @{$hosts};

is_deeply($host_from_item,
          $host_directly,
          '... and items can query the server for their own host')
    or diag(Dumper($host_from_item, $host_directly));
