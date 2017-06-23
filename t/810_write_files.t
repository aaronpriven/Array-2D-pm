use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

a2dcan('tsv_lines');
# high
# tsv_lines uses Ref::Util

a2dcan('tsv');
# high

a2dcan('file');
# high

a2dcan('xlsx');
# high

done_testing;
