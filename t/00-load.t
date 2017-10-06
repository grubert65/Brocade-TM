#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Brocade::TM' ) || print "Bail out!\n";
}

diag( "Testing Brocade::TM $Brocade::TM::VERSION, Perl $], $^X" );
