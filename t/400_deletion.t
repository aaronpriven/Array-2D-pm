use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

a2dcan('del_row');
# low

a2dcan('del_col');
# low

a2dcan('del_rows');
# low

a2dcan('del_cols');
# low

a2dcan('shift_row');
# high

a2dcan('shift_col');
# low

a2dcan('pop_row');
# low

a2dcan('pop_col');
# low

done_testing;
