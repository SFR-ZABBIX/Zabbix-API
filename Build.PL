use 5.010;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Zabbix::API',
    license             => 'perl',
    dist_author         => q{Fabrice Gabolde <fabrice.gabolde@uperto.com>},
    dist_version_from   => 'lib/Zabbix/API.pm',
    dist_abstract       => 'Access the JSON-RPC API of a Zabbix server',
    build_requires => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'File::Spec' => 0,
        'UNIVERSAL' => 0
    },
    requires => {
        'perl' => 5.010,
        'JSON' => 0,
        'LWP' => 0,
        'Params::Validate' => 0
    },
    add_to_cleanup      => [ 'Zabbix::API-*' ],
);

$builder->create_build_script();
