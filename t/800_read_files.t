use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing new_from_tsv()';
a2dcan('new_from_tsv');
#high

note 'Testing new_from_xlsx()';

a2dcan('new_from_xlsx');
#high

note 'Testing new_from_file()';
a2dcan('new_from_file');
#high

done_testing;
