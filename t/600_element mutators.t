use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing apply()';
a2dcan('apply');
# high

note 'Testing trim()';
a2dcan('trim');
# low

note 'Testing trim_right()';
a2dcan('trim_right');
# low

note 'Testing define()';
a2dcan('define');
# low

done_testing;
