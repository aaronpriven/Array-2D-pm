use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing del_row()';

ok(Array::2D->can('del_row'), 'Can del_row()');


note 'Testing del_col()';

ok(Array::2D->can('del_col'), 'Can del_col()');


note 'Testing del_rows()';

ok(Array::2D->can('del_rows'), 'Can del_rows()');


note 'Testing del_cols()';

ok(Array::2D->can('del_cols'), 'Can del_cols()');


note 'Testing shift_row()';

ok(Array::2D->can('shift_row'), 'Can shift_row()');


note 'Testing shift_col()';

ok(Array::2D->can('shift_col'), 'Can shift_col()');


note 'Testing pop_row()';

ok(Array::2D->can('pop_row'), 'Can pop_row()');


note 'Testing pop_col()';

ok(Array::2D->can('pop_col'), 'Can pop_col()');

done_testing;
