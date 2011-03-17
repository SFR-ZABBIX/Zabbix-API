use Test::More;
use Test::Exception;

if ($ENV{ZABBIX_SERVER}) {

    plan tests => 7;

} else {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok('Zabbix');

isa_ok(Zabbix::Host->new(
           _root => {},
           port => 1,
           ip => '2',
           status => 3,
           hostid => 4,
           error => 5,
           macros => [ 6, 7 ],
           host => '8'),
       'Zabbix::Host',
       '... and a newly-built Host');

my $extra = Zabbix::Host->new(
    _root => {},
    port => 1,
    ip => '2',
    status => 3,
    hostid => 4,
    error => 5,
    macros => [ 6, 7 ],
    host => '8',
    extra => 9);

isa_ok($extra, 'Zabbix::Host',
       '... and a newly-built Host with extra parameters');

ok(!exists $extra->{extra},
   '... and it does not keep those extra parameters');

my $zabber = Zabbix->new(server => $ENV{ZABBIX_SERVER},
                         verbosity => 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

$zabber->has_cookie or BAIL_OUT('Could not authenticate, something is wrong!');

my $hosts = $zabber->get_hosts(hostnames => ['Zabbix Server', 'Zibbax Server']);

is(@{$hosts}, 2, '... and we can fetch host data from the server');

isa_ok($hosts->[0], 'Zabbix::Host',
       '... and the object returned');

throws_ok(sub { Zabbix::Host->new(port => 1, ip => '2') },
          qr/^Zabbix::Host->new is missing parameters: _root status hostid error macros host\n/,
          '... and building a new Host with too few parameters croaks');

