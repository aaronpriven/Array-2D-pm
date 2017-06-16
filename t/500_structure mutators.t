use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing transpose()';

a2dcan('transpose');
# low


note 'Testing flattened()';

a2dcan('flattened');
# low

done_testing;
