use Test::More tests => 7;

BEGIN { use_ok 'Zabbix' };

my $zabber = new_ok('Zabbix', [ server => 'http://192.168.30.217/zabbix/api_jsonrpc.php' ]);

ok($zabber->get(method => 'apiinfo.version'),
   '... and querying Zabbix with a public method succeeds');

$zabber->authenticate(user => 'api',
                    password => 'kweh');

ok(!$zabber->has_cookie,
   '... and authenticating with incorrect login/pw fails');

ok(!$zabber->get(method => 'item.get'),
   '... and querying Zabbix with no auth cookie fails (assuming no API access is given to the public)');

$zabber->authenticate(user => 'api',
                    password => 'quack');

ok($zabber->has_cookie,
   '... and authenticating with correct login/pw succeeds');

ok($zabber->get(method => 'item.get',
                params => { filter => { host => 'Zabbix Server',
                                        key_ => 'system.uptime' } }),
   '... and querying Zabbix with auth cookie succeeds (assuming API access given to this user)');
