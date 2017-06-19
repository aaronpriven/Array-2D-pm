use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

a2dcan('apply');
# high

a2dcan('trim');
# low

a2dcan('trim_right');
# low

a2dcan('define');
# high

done_testing;
