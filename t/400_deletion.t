use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing del_row()';
a2dcan('del_row');
# low

note 'Testing del_col()';
a2dcan('del_col');
# low

note 'Testing del_rows()';
a2dcan('del_rows');
# low

note 'Testing del_cols()';
a2dcan('del_cols');
# low

note 'Testing shift_row()';
a2dcan('shift_row');
# high

note 'Testing shift_col()';
a2dcan('shift_col');
# low

note 'Testing pop_row()';
a2dcan('pop_row');
# low

note 'Testing pop_col()';
a2dcan('pop_col');
# low

done_testing;
