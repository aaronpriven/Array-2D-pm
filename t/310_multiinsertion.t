#!/usr/bin/env perl 
use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}


foreach my $method (
    qw/ins_rows ins_cols push_rows push_cols unshift_rows unshift_cols/)
{
    a2dcan($method);
}

# all low priority

done_testing;
