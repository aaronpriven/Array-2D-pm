use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    #<<<
    do './t/lib/construction.pl' //  # used in testing
      do './lib/construction.pl' //    # used syntax checking in Eclipse
      die "Can't load construction.pl";
    #>>>
}

note("Use Ref::Util functions for checking array references");

if ( eval { require Ref::Util; 1 } ) {
    test_construction();
}
else {
    plan skip_all => 'Ref::Util not available';
    done_testing;
}

