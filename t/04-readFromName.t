use strict;
use warnings;
use Brocade::TM ();
use Log::Log4perl qw(:easy);
use Data::Dumper  qw(Dumper);

Log::Log4perl->easy_init($DEBUG);

use Test::More;

ok(my $o=Brocade::TM->new(
        username    => $ENV{BROCADEVTM_USERNAME},
        password    => $ENV{BROCADEVTM_PASSWORD},
        server      => $ENV{BROCADEVTM_SERVER},
    ), 'new');

ok($o->workWithConfiguration(), 'workWithConfiguration' );
ok(my $virtual_servers = $o->readAll('virtual_servers'), 'readAll' );
note "Virtual servers:\n".Dumper($virtual_servers);

foreach my $ref ( @$virtual_servers ) {
    ok(my $obj = $o->readFromName('virtual_servers', $ref->{name}), 'readFromName');
    note "Virtual server $ref->{name}:\n".Dumper($obj);
}

done_testing;
