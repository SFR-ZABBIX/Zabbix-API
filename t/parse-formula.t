use Test::More tests => 2;

use_ok('Zabbix::Utils', qw/$RE_FORMULA/);

my $regexp = $RE_FORMULA;

my $string = q{last("Zabbix Server:net.if.in[eth0,bytes]")+last("Zibbax Server:do.stuff[bytes,lo0]")-blah("Nono le Robot:reticulate.splines[eth2,clous]")};

my @matches;

while ($string =~ m/$regexp/g) {

    my %foo = %+;

    push @matches, (\%foo);

}

is_deeply(\@matches,
          [ { function_call => 'last("Zabbix Server:net.if.in[eth0,bytes]")',
              function_args => '"Zabbix Server:net.if.in[eth0,bytes]"',
              host => 'Zabbix Server',
              item => 'net.if.in',
              item_arg => 'eth0,bytes' },
            { function_call => 'last("Zibbax Server:do.stuff[bytes,lo0]")',
              function_args => '"Zibbax Server:do.stuff[bytes,lo0]"',
              host => 'Zibbax Server',
              item => 'do.stuff',
              item_arg => 'bytes,lo0' },
            { function_call => 'blah("Nono le Robot:reticulate.splines[eth2,clous]")',
              function_args => '"Nono le Robot:reticulate.splines[eth2,clous]"',
              host => 'Nono le Robot',
              item => 'reticulate.splines',
              item_arg => 'eth2,clous' }, ],
          '... and a basic, correct formula is parsed');
