use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    $Array::2D::NO_REF_UTIL = 1;

    do './t/lib/dimensions.pl' // do './lib/dimensions.pl'
      // die "Can't load dimensions.pl";
}

note(q[Check array dimensions]);
note(q[ (This will also test whether the invocant is checked correctly,]);
note(q[  using perl's "ref" function)]);

test_dimensions();
