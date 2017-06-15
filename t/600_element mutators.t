use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing apply()';

ok(Array::2D->can('apply'), 'Can apply()');


note 'Testing trim()';

ok(Array::2D->can('trim'), 'Can trim()');


note 'Testing trim_right()';

ok(Array::2D->can('trim_right'), 'Can trim_right()');


note 'Testing define()';

ok(Array::2D->can('define'), 'Can define()');

done_testing;
