use strict;
use warnings;
use Brocade::TM ();
use Log::Log4perl qw(:easy);
use Data::Dumper  qw(Dumper);

Log::Log4perl->easy_init($INFO);

use Test::More;


ok(my $o=Brocade::TM->new(
        username    => $ENV{BROCADEVTM_USERNAME},
        password    => $ENV{BROCADEVTM_PASSWORD},
        server      => $ENV{BROCADEVTM_SERVER},
    ), 'new');

ok($o->workWithConfiguration(), 'workWithConfiguration' );
ok(my $config = $o->getConfigurationResources(), 'getConfigurationResources' );
note "Configuration Resources:\n".Dumper($config);

done_testing;
