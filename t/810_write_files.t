use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing tsv()';
a2dcan('tsv');
# high

note 'Testing file()';
a2dcan('file');
# high

note 'Testing xlsx()';
a2dcan('xlsx');
# high

done_testing;
