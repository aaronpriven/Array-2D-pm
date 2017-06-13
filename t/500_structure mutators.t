use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing transpose()';

ok(Array::2D->can('transpose'), 'Can transpose()');


note 'Testing flattened()';

ok(Array::2D->can('flattened'), 'Can flattened()');

done_testing;
