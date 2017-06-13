use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing new_to_term_width()';

ok(Array::2D->can('new_to_term_width'), 'Can new_to_term_width()');


note 'Testing tabulate_equal_width()';

ok(Array::2D->can('tabulate_equal_width'), 'Can tabulate_equal_width()');


note 'Testing tabulate()';

ok(Array::2D->can('tabulate'), 'Can tabulate()');


note 'Testing tabulated()';

ok(Array::2D->can('tabulated'), 'Can tabulated()');

done_testing;
