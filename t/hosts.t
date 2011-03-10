use Test::More tests => 3;

use_ok('Zabbix');

my $zabber = Zabbix->new(server => 'http://192.168.30.217/zabbix/api_jsonrpc.php',
                         verbosity => 0);

$zabber->authenticate(user => 'api',
                      password => 'quack');

$zabber->has_cookie or BAIL_OUT('Could not authenticate, something is wrong!');

my $hosts = $zabber->get_hosts(hostnames => ['Zabbix Server', 'Zibbax Server']);

ok(@{$hosts}, '... and we can fetch host data from the server');

is_deeply($hosts, [
              {
                  'port' => '10050',
                  'macros' => [],
                  'ip' => '127.0.0.1',
                  'status' => '0',
                  'hostid' => '10047',
                  'error' => '',
                  'host' => 'Zibbax Server'
              },
              {
                  'port' => '10050',
                  'macros' => [
                      {
                          'value' => '50',
                          'hostmacroid' => '1',
                          'macro' => '{$CAPPED_BITRATE}'
                      },
                      {
                          'value' => '5',
                          'hostmacroid' => '2',
                          'macro' => '{$CAPPED_BITRATE_TOLERANCE_DOWN}'
                      },
                      {
                          'value' => '5',
                          'hostmacroid' => '3',
                          'macro' => '{$CAPPED_BITRATE_TOLERANCE_UP}'
                      }
                      ],
                  'ip' => '127.0.0.1',
                  'status' => '0',
                  'hostid' => '10017',
                  'error' => '',
                  'host' => 'Zabbix Server'
              }
          ],
          '... and the data fetched is correct');
