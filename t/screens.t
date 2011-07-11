use Test::More tests => 15;
use Test::Exception;

use Zabbix::API;
use Zabbix::API::Graph;

unless ($ENV{ZABBIX_SERVER}) {

    plan skip_all => 'Needs an URL in $ENV{ZABBIX_SERVER} to run tests.';

}

use_ok('Zabbix::API::Screen');

my $zabber = Zabbix::API->new(server => $ENV{ZABBIX_SERVER},
                              verbosity => $ENV{ZABBIX_VERBOSITY} || 0);

eval { $zabber->login(user => 'api',
                      password => 'quack') };

if ($@) {

    my $error = $@;
    BAIL_OUT($error);

}

ok(my $default = $zabber->fetch('Screen', params => { search => { name => 'Zabbix server' } })->[0],
   '... and a screen known to exist can be fetched');

isa_ok($default, 'Zabbix::API::Screen',
       '... and that screen');

ok($default->created,
   '... and it returns true to existence tests');

my $screen = Zabbix::API::Screen->new(root => $zabber,
                                      data => { name => 'This screen brought to you by Zabbix::API' });

isa_ok($screen, 'Zabbix::API::Screen',
       '... and a screen created manually');

$screen->push;

ok($screen->created,
   '... and pushing the screen to the server creates a new screen');

$screen->data->{name} = 'Custom screen';

$screen->push;

$screen->pull; # ensure the data is refreshed

is($screen->data->{name},
   'Custom screen',
   '... and pushing a modified screen updates its data on the server');

throws_ok(sub { $screen->items([ { x => 1 } ]) },
          qr/Some screen items did not specify all their coordinates/,
          '... and adding screenitems without coordinates raises an exception');



my $graph = Zabbix::API::Graph->new(root => $zabber,
                                    data => { name => 'This graph brought to you by Zabbix::API' });

$graph->items([map { { item => $_ } }
               @{$zabber->fetch('Item', params => { search => { key_ => 'vm.memory' },
                                                    host => 'Zabbix Server' })}]);

lives_ok(sub { $screen->items([ { graph => $graph, 'x' => 0, 'y' => 0 } ]) },
         '... and adding screenitems with coordinates works');

is($screen->data->{hsize}, 1,
   '... and adding screenitems with coordinates sets the horizontal screen size');

is($screen->data->{vsize}, 1,
   '... and adding screenitems with coordinates sets the vertical screen size');

lives_ok(sub { $screen->push },
         '... and pushing a screen with a new graph works');

ok($graph->created, '... and the new graph is created on the server');

lives_ok(sub { $screen->delete }, '... and deleting a screen works');

ok(!$screen->created,
   '... and deleting a screen removes it from the server');

$graph->delete;

eval { $zabber->logout };
