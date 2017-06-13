use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

note 'Testing new_from_tsv()';

ok(Array::2D->can('new_from_tsv'), 'Can new_from_tsv()');

note 'Testing new_from_xlsx()';

ok(Array::2D->can('new_from_xlsx'), 'Can new_from_xlsx()');


note 'Testing new_from_file()';

ok(Array::2D->can('new_from_file'), 'Can new_from_file()');


note 'Testing tsv()';

ok(Array::2D->can('tsv'), 'Can tsv()');


note 'Testing file()';

ok(Array::2D->can('file'), 'Can file()');


note 'Testing xlsx()';

ok(Array::2D->can('xlsx'), 'Can xlsx()');

done_testing;
