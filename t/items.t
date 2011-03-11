use Test::More tests => 5;
use Test::Exception;

use_ok('Zabbix');

my $zabber = Zabbix->new(server => 'http://192.168.30.217/zabbix/api_jsonrpc.php',
                         verbosity => 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

$zabber->has_cookie or BAIL_OUT('Could not authenticate, something is wrong!');

my $items = $zabber->get_items(host => 'Zabbix Server',
                               key => 'system.uptime');

is(@{$items}, 1, '... and we can fetch item data from a single host with named-host-style invocation');

isa_ok($items->[0], 'Zabbix::Item',
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
