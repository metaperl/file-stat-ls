# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use strict;
use warnings;

use Test::More qw(no_plan); 

BEGIN { use_ok( 'File::Stat::Ls' ); }	

1;

