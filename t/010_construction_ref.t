use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    $Array::2D::NO_REF_UTIL = 1;
    do './t/lib/simple_construction.pl' // do './lib/simple_construction.pl'
      // die "Can't load simple_construction.pl";
}

note("Use perl's ref function for checking array references");

test_simple_construction();
