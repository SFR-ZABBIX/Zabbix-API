use Test::More;
use Test::Exception;
use Data::Dumper;

use Zabbix::API;

if ($ENV{ZABBIX_SERVER}) {

    plan tests => 4;

} else {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok('Zabbix::API::HostGroup');

my $zabber = Zabbix::API->new(server => $ENV{ZABBIX_SERVER},
                              verbosity => $ENV{ZABBIX_VERBOSITY} || 0);

eval { $zabber->login(user => 'api',
                      password => 'quack') };

if ($@) {

    my $error = $@;

    BAIL_OUT($error);

}

my $hosts = $zabber->fetch('HostGroup', params => { search => { name => 'Zabbix servers' } });

is(@{$hosts}, 1, '... and a host group known to exist can be fetched');

my $zabhost = $hosts->[0];

isa_ok($zabhost, 'Zabbix::API::HostGroup',
       '... and that host group');

ok($zabhost->created,
   '... and it returns true to existence tests');

eval { $zabber->logout };
