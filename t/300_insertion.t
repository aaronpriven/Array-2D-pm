use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing ins_row()';
a2dcan('ins_row');
# low priority

note 'Testing ins_col()';
a2dcan('ins_col');
# high priority

note 'Testing ins_rows()';
a2dcan('ins_rows');
# low

note 'Testing ins_cols()';
a2dcan('ins_cols');
#low

note 'Testing push_row()';
a2dcan('push_row');
# high

note 'Testing push_col()';
a2dcan('push_col');
# high

note 'Testing push_rows()';
a2dcan('push_rows');
# low

note 'Testing push_cols()';
a2dcan('push_cols');
# low

note 'Testing unshift_row()';
a2dcan('unshift_row');
# high

note 'Testing unshift_col()';
a2dcan('unshift_col');
# low

note 'Testing unshift_rows()';
a2dcan('unshift_rows');
#low

note 'Testing unshift_cols()';
a2dcan('unshift_cols');
# low

done_testing;
