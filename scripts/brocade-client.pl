#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: brocade-client.pl
#
#        USAGE: ./brocade-client.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Marco Masetti (marco.masetti@sky.ok)
# ORGANIZATION: SKY UK
#      VERSION: 1.0
#      CREATED: 09/26/2017 11:28:44
#     REVISION: ---
#===============================================================================
use strict;
use warnings;
use utf8;
use Log::Log4Perl qw(:easy);
use Brocade::TM ();

Log::Log4perl->easy_init($DEBUG);

