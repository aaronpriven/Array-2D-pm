use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    do './t/lib/simple_construction.pl' // do './lib/simple_construction.pl'
      // die "Can't load simple_construction.pl";
}

note("Use Ref::Util functions for checking array references");

if ( eval { require Unicode::GCString; 1 } ) {
    test_simple_construction();
}
else {
    test_simple_construction('skip');
}

