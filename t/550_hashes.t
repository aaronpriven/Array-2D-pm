use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing hash_of_rows()';

a2dcan('hash_of_rows');
# low


note 'Testing hash_of_row_elements()';

a2dcan('hash_of_row_elements');

# low

done_testing;
