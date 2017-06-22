use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
    do './t/lib/tabulation.pl' // do './lib/tabulation.pl'
      // die "Can't load tabulation.pl";
}

note('Use Unicode::GCString for determining column widths');

use Array::2D;

# Add Unicode tests here

if ( eval { require Unicode::GCString; 1 } ) {
    run_tabulation_tests();
}
else {
    run_tabulation_tests('skip');
}
