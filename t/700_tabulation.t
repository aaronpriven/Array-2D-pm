use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing new_to_term_width()';
a2dcan('new_to_term_width');
# high

note 'Testing tabulate_equal_width()';
a2dcan('tabulate_equal_width');
# high

note 'Testing tabulate()';
a2dcan('tabulate');
# high

note 'Testing tabulated()';
a2dcan('tabulated');
# high

done_testing;
