use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing ins_row()';

ok(Array::2D->can('ins_row'), 'Can ins_row()');


note 'Testing ins_col()';

ok(Array::2D->can('ins_col'), 'Can ins_col()');


note 'Testing ins_rows()';

ok(Array::2D->can('ins_rows'), 'Can ins_rows()');


note 'Testing ins_cols()';

ok(Array::2D->can('ins_cols'), 'Can ins_cols()');


note 'Testing push_row()';

ok(Array::2D->can('push_row'), 'Can push_row()');


note 'Testing push_col()';

ok(Array::2D->can('push_col'), 'Can push_col()');


note 'Testing push_rows()';

ok(Array::2D->can('push_rows'), 'Can push_rows()');


note 'Testing push_cols()';

ok(Array::2D->can('push_cols'), 'Can push_cols()');


note 'Testing unshift_row()';

ok(Array::2D->can('unshift_row'), 'Can unshift_row()');


note 'Testing unshift_col()';

ok(Array::2D->can('unshift_col'), 'Can unshift_col()');


note 'Testing unshift_rows()';

ok(Array::2D->can('unshift_rows'), 'Can unshift_rows()');


note 'Testing unshift_cols()';

ok(Array::2D->can('unshift_cols'), 'Can unshift_cols()');

done_testing;
