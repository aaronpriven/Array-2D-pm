use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing prune()';

ok(Array::2D->can('prune'), 'Can prune()');


note 'Testing prune_empty()';

ok(Array::2D->can('prune_empty'), 'Can prune_empty()');


note 'Testing prune_space()';

ok(Array::2D->can('prune_space'), 'Can prune_space()');


note 'Testing prune_callback()';

ok(Array::2D->can('prune_callback'), 'Can prune_callback()');


note 'Testing apply()';

ok(Array::2D->can('apply'), 'Can apply()');


note 'Testing trim()';

ok(Array::2D->can('trim'), 'Can trim()');


note 'Testing trim_right()';

ok(Array::2D->can('trim_right'), 'Can trim_right()');


note 'Testing define()';

ok(Array::2D->can('define'), 'Can define()');

done_testing;
