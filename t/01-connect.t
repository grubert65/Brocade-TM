use strict;
use warnings;
use Brocade::TM ();
use Log::Log4perl qw(:easy);
use Data::Dumper  qw(Dumper);

Log::Log4perl->easy_init($DEBUG);

use Test::More;

SKIP: {
    skip 2, "Environment not set" unless $ENV{BROCADEVTM_SERVER};
    ok(my $o=Brocade::TM->new(
        username    => $ENV{BROCADEVTM_USERNAME},
        password    => $ENV{BROCADEVTM_PASSWORD},
        server      => $ENV{BROCADEVTM_SERVER},
    ), 'new');

    ok(my $versions = $o->supported_versions, 'Supported versions' );
    note "Supported versions:\n".Dumper($versions);
}

done_testing;


