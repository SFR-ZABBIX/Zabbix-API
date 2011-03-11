use Test::More tests => 3;

use_ok('Zabbix');

my $zabber = Zabbix->new(server => 'http://192.168.30.217/zabbix/api_jsonrpc.php',
                         verbosity => 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

$zabber->has_cookie or BAIL_OUT('Could not authenticate, something is wrong!');

my $hosts = $zabber->get_hosts(hostnames => ['Zabbix Server', 'Zibbax Server']);

is(@{$hosts}, 2, '... and we can fetch host data from the server');

isa_ok($hosts->[0], 'Zabbix::Host',
       '... and the object returned');
