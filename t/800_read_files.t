use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

a2dcan('new_from_tsv');
#high


a2dcan('new_from_xlsx');
#high

a2dcan('new_from_file');
#high

done_testing;
