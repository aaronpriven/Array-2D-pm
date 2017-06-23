use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    $Array::2D::NO_REF_UTIL = 1;

    #<<<
    do './t/lib/construction.pl' //  # used in testing
      do './lib/construction.pl' //  # used syntax checking in Eclipse
      die "Can't load construction.pl";
    #>>>
}

note("Use perl's ref function for checking array references");

test_construction();
