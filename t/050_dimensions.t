use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing height()';

ok(Array::2D->can('height'), 'Can height()');


note 'Testing width()';

ok(Array::2D->can('width'), 'Can width()');


note 'Testing last_row()';

ok(Array::2D->can('last_row'), 'Can last_row()');


note 'Testing last_col()';

ok(Array::2D->can('last_col'), 'Can last_col()');

done_testing;
