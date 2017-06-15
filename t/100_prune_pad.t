use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing prune()';

a2dcan('prune');

note 'Testing prune_empty()';

a2dcan('prune_empty');


note 'Testing prune_space()';

a2dcan('prune_space');

note 'Testing prune_callback()';

a2dcan('prune_callback');

note 'Testing pad()';

a2dcan('pad');

done_testing;
