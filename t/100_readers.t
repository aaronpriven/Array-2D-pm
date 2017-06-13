use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing element()';

ok(Array::2D->can('element'), 'Can element()');


note 'Testing row()';

ok(Array::2D->can('row'), 'Can row()');


note 'Testing col()';

ok(Array::2D->can('col'), 'Can col()');


note 'Testing rows()';

ok(Array::2D->can('rows'), 'Can rows()');


note 'Testing cols()';

ok(Array::2D->can('cols'), 'Can cols()');


note 'Testing slice()';

ok(Array::2D->can('slice'), 'Can slice()');

done_testing;
