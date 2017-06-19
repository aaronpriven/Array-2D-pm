use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

a2dcan('new_to_term_width');
# high

a2dcan('tabulate_equal_width');
# high

a2dcan('tabulate');
# high

a2dcan('tabulated');
# high

done_testing;
