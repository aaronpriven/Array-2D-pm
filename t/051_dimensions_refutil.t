use strict;
use warnings;
use Test::More 0.98;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
    do './t/lib/dimensions.pl' // do './lib/dimensions.pl'
      // die "Can't load dimensions.pl";
}

note(q[Check array dimensions]);
note(q[ (This will also test whether the invocant is checked correctly,]);
note(q[  using Ref::Util functions)]);

if ( eval { require Ref::Util; 1 } ) {
    test_dimensions();
}
else {
    test_dimensions('skip');
}
