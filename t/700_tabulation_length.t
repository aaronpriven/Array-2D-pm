use strict;
use warnings;

BEGIN {
    do './t/lib/tabulation.pl' // do './lib/tabulation.pl'
      // die "Can't load tabulation.pl";
}

BEGIN { 
  $Array::2D::NO_GCSTRING = 1;
}

use Array::2D;

note("Use perl's length function for determining text column widths");

run_tabulation_tests(); 
