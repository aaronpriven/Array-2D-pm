use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing hash_of_rows()';

ok(Array::2D->can('hash_of_rows'), 'Can hash_of_rows()');


note 'Testing hash_of_row_elements()';

ok(Array::2D->can('hash_of_row_elements'), 'Can hash_of_row_elements()');

done_testing;
