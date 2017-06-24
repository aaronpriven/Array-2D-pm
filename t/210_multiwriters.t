use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

a2dcan('set_rows');
# low priority

a2dcan('set_cols');
# low priority

a2dcan('set_slice');
# low priority

done_testing;
