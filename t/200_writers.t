use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing set_element()';

ok(Array::2D->can('set_element'), 'Can set_element()');


note 'Testing set_row()';

ok(Array::2D->can('set_row'), 'Can set_row()');


note 'Testing set_col()';

ok(Array::2D->can('set_col'), 'Can set_col()');


note 'Testing set_rows()';

ok(Array::2D->can('set_rows'), 'Can set_rows()');


note 'Testing set_cols()';

ok(Array::2D->can('set_cols'), 'Can set_cols()');


note 'Testing set_slice()';

ok(Array::2D->can('set_slice'), 'Can set_slice()');

done_testing;
