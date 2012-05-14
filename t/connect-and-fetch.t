use Test::More;
use Test::Exception;

if ($ENV{ZABBIX_SERVER}) {

    plan tests => 9;

} else {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok 'Zabbix::API';

my $zabber = new_ok('Zabbix::API', [ server => $ENV{ZABBIX_SERVER}, verbosity => $ENV{ZABBIX_VERBOSITY} || 0 ]);

ok($zabber->query(method => 'apiinfo.version'),
   '... and querying Zabbix with a public method succeeds');

eval { $zabber->login(user => 'api', password => 'kweh') };

ok(!$zabber->cookie,
   '... and authenticating with incorrect login/pw fails');

dies_ok(sub { $zabber->query(method => 'item.get',
                             params => { filter => { host => 'Zabbix Server',
                                                     key_ => 'system.uptime' } }) },
        '... and querying Zabbix with no auth cookie fails (assuming no API access is given to the public)');

eval { $zabber->login(user => 'api_access', password => 'api') };

ok($zabber->cookie,
   '... and authenticating with correct login/pw succeeds');

ok($zabber->query(method => 'item.get',
                  params => { filter => { host => 'Zabbix Server',
                                          key_ => 'system.uptime' } }),
   '... and querying Zabbix with auth cookie succeeds (assuming API access given to this user)');

TODO: {

    local $TODO = 'user.logout is not documented *at all*';

    eval { $zabber->logout };

    ok(!$zabber->cookie,
       '... and logging out removes the cookie from the object');

}

throws_ok(sub { my $fakezabber = Zabbix::API->new(server => 'http://google.com');
                $fakezabber->{ua}->timeout(5);
                $fakezabber->login(user => 'api', password => 'kweh') },
          qr/^Could not connect/,
          '... and trying to log to a random URI fails');
