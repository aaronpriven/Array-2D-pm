use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

a2dcan('hash_of_rows');
# low

a2dcan('hash_of_row_elements');
# low

done_testing;
