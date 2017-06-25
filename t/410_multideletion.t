#!/usr/bin/env perl 
use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}


foreach my $method ( qw/del_cols del_rows/) {
    a2dcan($method);
}

# all low priority

done_testing;
