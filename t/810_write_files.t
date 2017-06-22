use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

a2dcan('tsv_lines');
# high

a2dcan('tsv');
# high

a2dcan('file');
# high

a2dcan('xlsx');
# high

done_testing;
