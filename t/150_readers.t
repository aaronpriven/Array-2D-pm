use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our $sample_ref;
our ( $one_row_ref, $one_row_test );
our ( $one_col_ref, $one_col_test );

my @element_tests = (
    [ 0,  0,  'Fetched top left element',                'Joshua' ],
    [ 9,  2,  'Fetched element from last row',           'San Francisco' ],
    [ 2,  4,  'Fetched element from last column',        'Michael' ],
    [ 2,  2,  'Fetched an element from middle',          'Dallas' ],
    [ -1, 0,  'Fetched an element with negative row',    'Joseph' ],
    [ 2,  -2, 'Fetched an element with negative column', 'Aix-en-Provence' ],
    [ 1,  3,  'Fetched an element set to undef' ],
    [ 3,  4,  'Fetched an empty element' ],
    [ 12, 2,  'Fetched element from nonexistent row' ],
    [ 2,  6,  'Fetched element from nonexistent column' ],
    [ -20, 0,  'Fetched element from nonexistent negative row' ],
    [ 0,   -9, 'Fetched element from nonexistent negative column' ],
    [ 0,   0,  'Fetched element from one-element array', 'x', [ ['x'] ], ],
    [ 0,   1,  'Fetched element from one-row array', 'x', [ [ 1, 'x' ] ], ],
    [ 1,   0,  'Fetched element from one-column array', 'x', [ [1], ['x'] ], ],
    [ 1, 1, 'Fetched nonexistent element from empty object', undef, [], ],
);

my @row_tests = (
    [   0,
        [ 'Joshua', 29, 'San Mateo', undef, 'Hannah' ],
        'full row from beginning',
    ],
    [   2,
        [ 'Emily', 25, 'Dallas', 'Aix-en-Provence', 'Michael' ],
        'full row from middle',
    ],
    [ 7, [ 'Ashley', 57, 'Ray' ],           'partial row from middle' ],
    [ 9, [ 'Joseph', 0,  'San Francisco' ], 'partial row from end' ],
    [   -2,
        [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
        'row with negative index'
    ],
    [ 10,  [], 'nonexistent row' ],
    [ -20, [], 'nonexistent negative row' ],
    [ 0,   [], 'row from empty array', [] ],
    [ 0, $one_row_test, 'row from one-row array', $one_row_ref ],
    [ 1, ['Helvetica'], 'row from one-column array', $one_col_ref ],
);

my @col_tests = (
    [   0,
        [   'Joshua',  'Christopher', 'Emily',  'Nicholas',
            'Madison', 'Andrew',      'Hannah', 'Ashley',
            'Alexis',  'Joseph',
        ],
        'full column from beginning',
    ],
    [   1,
        [ 29, 59, 25, -14, 8, -15, 38, 57, 50, 0, ],
        'full column from middle',
    ],
    [ 3, [ undef, undef, 'Aix-en-Provence' ], 'partial column from middle', ],
    [   4,
        [   'Hannah', 'Alexis', 'Michael', undef,
            undef,    undef,    'Joshua',  undef,
            'Christopher'
        ],
        'partial column from end',
    ],
    [   -3,
        [   'San Mateo',  'New York City', 'Dallas', undef,
            'Vallejo',    undef,           'Romita', 'Ray',
            'San Carlos', 'San Francisco',
        ],
        'column with negative index',
    ],
    [ 6,  [], 'nonexistent column' ],
    [ -9, [], 'nonexistent negative column' ],
    [ 0,  [], 'column from empty array', [] ],
    [ 0, $one_col_test, 'column from one-column array', $one_col_ref ],
    [ 2, ['Union City'], 'column from one-row array', $one_row_ref ],
);

plan( tests => ( 4 * ( @row_tests + @col_tests + @element_tests ) + 3 ) );
# 4 tests per entry, plus 3, one for each method

sub test_reader {
    my ( $method, $description, $indices, $expected_results, $test_array ) = @_;
    $test_array ||= $sample_ref;

    my $ref_to_test = Array::2D->clone_unblessed($test_array);
    my $obj_to_test = Array::2D->clone($test_array);

    is_deeply( [ $obj_to_test->$method(@$indices) ],
        $expected_results, "$description: object" );
    is_deeply( $obj_to_test, $test_array,
        '... and it did not alter the object' );
    is_deeply( [ Array::2D->$method( $ref_to_test, @$indices ) ],
        $expected_results, "$description: reference" );
    is_deeply( $ref_to_test, $test_array,
        '... and it did not alter the reference' );
}

a2dcan('element');

for my $test_r (@element_tests) {
    my ( $row, $col, $description, $expected_results, $test_array ) = @$test_r;
    my $indices = [ $row, $col ];
    test_reader( 'element', $description, $indices, [$expected_results],
        $test_array );
}

a2dcan('row');

for my $test_r (@row_tests) {
    my ( $row, $expected_results, $description, $test_array ) = @$test_r;
    my $indices = [$row];
    test_reader( 'row', "Fetched $description",
        $indices, $expected_results, $test_array );
}

a2dcan('col');

for my $test_r (@col_tests) {
    my ( $col, $expected_results, $description, $test_array ) = @$test_r;
    my $indices = [$col];
    test_reader( 'col', "Fetched $description",
        $indices, $expected_results, $test_array );
}

done_testing;
