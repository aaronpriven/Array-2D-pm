use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $sample_obj,            $sample_ref,            $sample_test );
our ( $sample_transposed_obj, $sample_transposed_ref, $sample_transposed_test );
our ( $empty_obj,             $empty_ref );

plan tests => 652;

note 'Testing element()';
a2dcan('element');

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
);

for my $test_r (@element_tests) {
    my ( $row, $col, $description, $value, $test_change ) = @$test_r;
    # value should often be set to undef because it's not listed
    is( $sample_obj->element( $row, $col ),
        $value, "$description: sample object" );
    is_deeply( $sample_obj, $sample_test,
        '... and it did not alter the object' );
    is( Array::2D->element( $sample_ref, $row, $col ),
        $value, "$description: sample reference" );
    is_deeply( $sample_ref, $sample_test,
        '... and it did not alter the reference' );
}

is( $empty_obj->element( 1, 1 ),
    undef, 'Fetched nonexistent element from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is( Array::2D->element( $empty_ref, 1, 1 ),
    undef, 'Fetched nonexistent element from empty object' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

note 'Testing row()';
a2dcan('row');

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
);

# row returns a list, so we have to create anonymous arrayref to test
for my $test_r (@row_tests) {
    my ( $idx, $test_against, $description ) = @$test_r;
    is_deeply( [ $sample_obj->row($idx) ],
        $test_against, "Fetched $description: sample object" );
    is_deeply( $sample_obj, $sample_test,
        '... and it did not alter the object' );
    is_deeply( [ Array::2D->row( $sample_ref, $idx ) ],
        $test_against, "Fetched $description: sample reference" );
    is_deeply( $sample_ref, $sample_test,
        '... and it did not alter the reference' );
}

is_deeply( [ $empty_obj->row(1) ],
    [], 'Fetched nonexistent row from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( [ Array::2D->row( $empty_ref, 1 ) ],
    [], 'Fetched nonexistent row from empty reference' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

note 'Testing col()';
a2dcan('col');

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
);

# col returns a list, so we have to create anonymous arrayref to test
for my $test_r (@col_tests) {
    my ( $idx, $test_against, $description ) = @$test_r;
    is_deeply( [ $sample_obj->col($idx) ],
        $test_against, "Fetched $description: sample object" );
    #note( explain( $sample_obj->col($idx) ) );
    is_deeply( $sample_obj, $sample_test,
        '... and it did not alter the object' );
    is_deeply( [ Array::2D->col( $sample_ref, $idx ) ],
        $test_against, "Fetched $description: sample reference" );
    is_deeply( $sample_ref, $sample_test,
        '... and it did not alter the reference' );
}

is_deeply( [ $empty_obj->col(1) ],
    [], 'Fetched nonexistent column from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( [ Array::2D->col( $empty_ref, 1 ) ],
    [], 'Fetched nonexistent column from empty reference' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

my @rows_cols_tests = (
    {   indices      => [ 0, 1 ],
        test_against => [
            [ 'Joshua',      29, 'San Mateo',     undef, 'Hannah' ],
            [ 'Christopher', 59, 'New York City', undef, 'Alexis' ],
        ],
        description => 'first two',
    },
    {   indices      => [ 7, 8, 9 ],
        test_against => [
            [ 'Ashley', 57, 'Ray' ],
            [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
            [ 'Joseph', 0,  'San Francisco' ],
        ],
        description => 'last three',
    },
    {   indices => [ 4, 5 ],
        test_against => [ [ 'Madison', 8, 'Vallejo' ], [ 'Andrew', -15, ], ],
        description => 'two middle',
    },
    {   indices      => [ -1, -2 ],
        test_against => [
            [ 'Joseph', 0, 'San Francisco' ],
            [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
        ],
        description => 'last two using negative subscripts',
    },

    {   indices      => [ 2, 8 ],
        test_against => [
            [ 'Emily',  25, 'Dallas',     'Aix-en-Provence', 'Michael' ],
            [ 'Alexis', 50, 'San Carlos', undef,             'Christopher' ],
        ],
        description => 'Two non-adjacent',
    },

    {   indices => [ 5, 3 ],
        test_against => [ [ 'Andrew', -15, ], [ 'Nicholas', -14, ], ],
        description => 'Two non-adjacent, in reverse order',
    },
    {   indices      => [ 11, 12 ],
        test_against => [],
        description  => 'nonexsitent',
    },
    {   indices      => [ -20, -21 ],
        test_against => [],
        description  => 'nonexsitent, with negative subscripts',
    },
    {   indices      => [ 8, 9, 10 ],
        test_against => [
            [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
            [ 'Joseph', 0,  'San Francisco' ],
        ],
        description => 'range, including a nonexistent one',
    },
    {   indices => [ 5, 5 ],
        test_against => [ [ 'Andrew', -15, ], [ 'Andrew', -15, ], ],
        description => 'two duplicates',
    },

);

sub test_rows_or_cols {

    for my $test_r (@rows_cols_tests) {
        my @indices      = @{ $test_r->{indices} };
        my $test_against = $test_r->{test_against};
        my $description  = $test_r->{description};

        my $sample_obj_result = $sample_obj->rows(@indices);
        is_deeply( $sample_obj_result,
            $test_against, "Fetched rows: $description: sample object" );
        is_deeply( $sample_obj, $sample_test,
            '... and it did not alter the object' );
        is_blessed($sample_obj_result);

        my $sample_ref_result = Array::2D->rows( $sample_ref, @indices );
        is_deeply( $sample_ref_result,
            $test_against, "Fetched rows: $description: sample reference" );
        is_deeply( $sample_ref, $sample_test,
            '... and it did not alter the reference' );
        is_blessed($sample_ref_result);

        my $sample_transposed_obj_result
          = $sample_transposed_obj->cols(@indices);
        is_deeply( $sample_transposed_obj_result,
            $test_against, "Fetched cols: $description: sample object" );
        is_deeply( $sample_transposed_obj, $sample_transposed_test,
            '... and it did not alter the object' );
        is_blessed($sample_transposed_obj_result);

        my $sample_transposed_ref_result
          = Array::2D->rows( $sample_ref, @indices );
        is_deeply( $sample_transposed_ref_result,
            $test_against, "Fetched cols: $description: sample reference" );
        is_deeply( $sample_transposed_ref, $sample_transposed_test,
            '... and it did not alter the reference' );
        is_blessed($sample_transposed_ref_result);

    } ## tidy end: for my $test_r (@rows_cols_tests)

} ## tidy end: sub test_rows_or_cols

note 'Testing rows()';
a2dcan('rows');

test_rows_or_cols();

is_deeply( $empty_obj->rows( 1, 2 ),
    [], 'Fetched nonexistent rows from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( Array::2D->rows( $empty_ref, 1, 2 ),
    [], 'Fetched nonexistent rows from empty reference' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

note 'Testing cols()';
a2dcan('cols');

test_rows_or_cols();

is_deeply( $empty_obj->cols( 1, 2 ),
    [], 'Fetched nonexistent columns from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( Array::2D->cols( $empty_ref, 1, 2 ),
    [], 'Fetched nonexistent columns from empty reference' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

note 'Testing slice_cols()';
a2dcan('slice_cols');

my @slice_cols_tests = (
    {   indices      => [ 0, 1 ],
        test_against => [
            [ 'Joshua',      29 ],
            [ 'Christopher', 59, ],
            [ 'Emily',       25, ],
            [ 'Nicholas',    -14, ],
            [ 'Madison',     8, ],
            [ 'Andrew',      -15, ],
            [ 'Hannah',      38, ],
            [ 'Ashley',      57, ],
            [ 'Alexis',      50, ],
            [ 'Joseph',      0, ],

        ],
        description => 'first two',
    },
    {   indices      => [ 2, 3, 4 ],
        test_against => [

            [ 'San Mateo',     undef,             'Hannah' ],
            [ 'New York City', undef,             'Alexis' ],
            [ 'Dallas',        'Aix-en-Provence', 'Michael' ],
            [],
            ['Vallejo'],
            [],
            [ 'Romita', undef, 'Joshua', ],
            ['Ray'],
            [ 'San Carlos', undef, 'Christopher' ],
            ['San Francisco'],

        ],
        description => 'last three',
    },
    {   indices      => [ 1, 2 ],
        test_against => [
            [ 29, 'San Mateo' ],
            [ 59, 'New York City' ],
            [ 25, 'Dallas' ],
            [ -14, ],
            [ 8, 'Vallejo' ],
            [ -15, ],
            [ 38, 'Romita' ],
            [ 57, 'Ray' ],
            [ 50, 'San Carlos' ],
            [ 0,  'San Francisco' ],
        ],
        description => 'two middle',
    },
    {   indices      => [ -2, -1 ],
        test_against => [
            [ undef,             'Hannah' ],
            [ undef,             'Alexis' ],
            [ 'Aix-en-Provence', 'Michael' ],
            [],
            [],
            [],
            [ undef, 'Joshua', ],
            [],
            [ undef, 'Christopher' ],
        ],
        description => 'last two using negative subscripts',
    },
    {   indices      => [ 1, 4 ],
        test_against => [
            [ 29, 'Hannah' ],
            [ 59, 'Alexis' ],
            [ 25, 'Michael' ],
            [ -14, ],
            [ 8, ],
            [ -15, ],
            [ 38, 'Joshua' ],
            [ 57, ],
            [ 50, 'Christopher' ],
            [ 0, ],
        ],
        description => 'Two non-adjacent',
    },
    {   indices      => [ 4, 0 ],
        test_against => [

            [ 'Hannah',      'Joshua' ],
            [ 'Alexis',      'Christopher' ],
            [ 'Michael',     'Emily' ],
            [ undef,         'Nicholas' ],
            [ undef,         'Madison' ],
            [ undef,         'Andrew' ],
            [ 'Joshua',      'Hannah' ],
            [ undef,         'Ashley' ],
            [ 'Christopher', 'Alexis' ],
            [ undef,         'Joseph' ],
        ],
        description => 'Two non-adjacent, in reverse order',
    },
    {   indices      => [ 11, 12 ],
        test_against => [],
        description  => 'nonexsitent',
    },
    {   indices      => [ -20, -21 ],
        test_against => [],
        description  => 'nonexsitent, with negative subscripts',
    },
    {   indices      => [ 3, 4, 5 ],
        test_against => [

            [ undef,             'Hannah' ],
            [ undef,             'Alexis' ],
            [ 'Aix-en-Provence', 'Michael' ],
            [],
            [],
            [],
            [ undef, 'Joshua', ],
            [],
            [ undef, 'Christopher' ],
        ],
        description => 'range, including a nonexistent one',
    },
    {   indices      => [ 1, 1 ],
        test_against => [
            [ 29,  29, ],
            [ 59,  59, ],
            [ 25,  25, ],
            [ -14, -14 ],
            [ 8,   8 ],
            [ -15, -15 ],
            [ 38,  38 ],
            [ 57,  57 ],
            [ 50,  50 ],
            [ 0,   0 ],
        ],
        description => 'two duplicates',
    },

);

for my $test_r (@slice_cols_tests) {
    my @indices      = @{ $test_r->{indices} };
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};

    my $sample_obj_result = $sample_obj->slice_cols(@indices);

    is_deeply( $sample_obj_result,
        $test_against, "Fetched sliced cols: $description: sample object" );
    is_deeply( $sample_obj, $sample_test,
        '... and it did not alter the object' );
    is_blessed($sample_obj_result);

    my $sample_ref_result = Array::2D->slice_cols( $sample_ref, @indices );
    is_deeply( $sample_ref_result,
        $test_against, "Fetched sliced cols: $description: sample reference" );
    is_deeply( $sample_ref, $sample_test,
        '... and it did not alter the reference' );
    is_blessed($sample_ref_result);

} ## tidy end: for my $test_r (@slice_cols_tests)

is_deeply( $empty_obj->slice_cols( 1, 2 ),
    [], 'Fetched nonexistent sliced cols from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( Array::2D->slice_cols( $empty_ref, 1, 2 ),
    [], 'Fetched nonexistent sliced cols from empty reference' );

note 'Testing slice()';
a2dcan('slice');

my @slice_tests = (
    {   indices      => [ 0, 1, 0, 1 ],
        test_against => [
            [ 'Joshua',      29 ],
            [ 'Christopher', 59, ],

        ],
        description => '2x2: upper left corner',
    },
    {   indices      => [ 7, 9, 2, 4 ],
        test_against => [
            ['Ray'], [ 'San Carlos', undef, 'Christopher' ],
            ['San Francisco'],
        ],
        description => '3x3: lower right corner',
    },
    {   indices      => [ 6, 9, 0, 3 ],
        test_against => [

            [ 'Hannah', 38, 'Romita', ],
            [ 'Ashley', 57, 'Ray' ],
            [ 'Alexis', 50, 'San Carlos', ],
            [ 'Joseph', 0,  'San Francisco' ],

        ],
        description => '4x4: lower left corner',
    },
    {   indices => [ 8, 9, 3, 4 ],
        test_against => [ [ undef, 'Christopher' ] ],
        description => '2x2: lower right corner, including blank row area',
    },
    {   indices      => [ 0, 1, -2, -1 ],
        test_against => [

            [ undef, 'Hannah' ],
            [ undef, 'Alexis' ],

        ],
        description => '2x2: upper right, negative column subscripts',
    },
    {   indices      => [ -1, -2, 0, 1 ],
        test_against => [
            [ 'Alexis', 50, ],
            [ 'Joseph', 0, ],

        ],
        description => '2x2: lower left, negative row subscripts',
    },
    {   indices => [ 2, 4, 1, 3 ],
        test_against =>
          [ [ 25, 'Dallas', 'Aix-en-Provence', ], [ -14, ], [ 8, 'Vallejo' ], ],
        description => '3x3: middle',
    },

    {   indices => [ 6, 8, 3, 4 ],
        test_against => [ [ undef, 'Joshua' ], [], [ undef, 'Christopher' ], ],
        description => 'with empty row',
    },
    {   indices      => [ 3, 4, 4, 5 ],
        test_against => [],
        description  => 'entirely empty',
    },
    {   indices => [ 0, 1, 4, 5 ],
        test_against => [ ['Hannah'], ['Alexis'], ],
        description => 'partially off the right edge',
    },
    {   indices => [ 9, 10, 0, 1 ],
        test_against => [ [ 'Joseph', 0 ] ],
        description => 'partially off the bottom edge',
    },
    {   indices      => [ 7, 10, 2, 5 ],
        test_against => [
            ['Ray'], [ 'San Carlos', undef, 'Christopher' ],
            ['San Francisco'],
        ],
        description => 'partially off both bottom and right edges',
    },
    {   indices      => [ 0, 1, 10, 11 ],
        test_against => [],
        description  => 'entirely off right'
    },
    {   indices      => [ 15, 16, 0, 1 ],
        test_against => [],
        description  => 'entirely off both bottom and right',
    },
    {   indices      => [ 20, 21, 20, 21 ],
        test_against => [],
        description  => 'entirely off left'
    },
    {   indices      => [ 0, 1, -10, -11 ],
        test_against => [],
        description  => 'entirely off top',
    },
    {   indices      => [ -15, -16, 0, 1 ],
        test_against => [],
        description  => 'entirely off top',
    },
    {   indices      => [ -15, -16, -15, -16 ],
        test_against => [],
        description  => 'entirely off both left and top',
    },
    {   indices => [ 2, 1, 1, 2 ],
        test_against => [ [ 59, 'New York City' ], [ 25, 'Dallas', ], ],
        description => '2x2: reverse row order specified',
    },
    {   indices => [ 4, 7, 4, 2 ],
        test_against =>
          [ ['Vallejo'], [], [ 'Romita', undef, 'Joshua', ], ['Ray'], ],
        description => '3x3: reverse column order specified',
    },
    {   indices => [ 9, 7, 1, 0 ],
        test_against =>
          [ [ 'Ashley', 57, ], [ 'Alexis', 50, ], [ 'Joseph', 0, ], ],
        description => '3x2: reverse row and column order specified',
    },
);

for my $test_r (@slice_tests) {
    my @indices      = @{ $test_r->{indices} };
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};

    my $sample_obj_result = $sample_obj->slice(@indices);

    is_deeply( $sample_obj_result,
        $test_against, "Sliced: $description: sample object" );
    is_deeply( $sample_obj, $sample_test,
        '... and it did not alter the object' );
    is_blessed($sample_obj_result);

    my $sample_ref_result = Array::2D->slice( $sample_ref, @indices );
    is_deeply( $sample_ref_result,
        $test_against, "Fetched rows: $description: sample reference" );
    is_deeply( $sample_ref, $sample_test,
        '... and it did not alter the reference' );
    is_blessed($sample_ref_result);

    # we already tested cloning, so this should be ok

    my $sample_obj_clone = $sample_obj->clone;
    $sample_obj_clone->slice(@indices);
    is_deeply( $sample_obj_clone,
        $test_against, "Sliced in place: $description: sample object" );
    is_blessed($sample_obj_clone);

    my $sample_ref_clone = Array::2D->clone_unblessed($sample_ref);
    Array::2D->slice( $sample_ref_clone, @indices );
    is_deeply( $sample_ref_clone,
        $test_against, "Sliced in place: $description: sample reference" );
    isnt_blessed($sample_ref_clone);

} ## tidy end: for my $test_r (@slice_tests)

is_deeply( $empty_obj->slice( 1, 2, 1, 2 ),
    [], 'Fetched nonexistent slice from empty object' );
is_deeply( $empty_obj, [], '... and it did not alter the object' );
is_deeply( Array::2D->slice( $empty_ref, 1, 2, 1, 2 ),
    [], 'Fetched nonexistent slice from empty reference' );
is_deeply( $empty_ref, [], '... and it did not alter the reference' );

my $empty_obj_to_slice = Array::2D->empty;
my $empty_ref_to_slice = [];

is_deeply( $empty_obj_to_slice->slice( 1, 2, 1, 2 ),
    [], 'Slice in place empty object' );
is_deeply( $empty_obj_to_slice, [], "... and it's still empty" );
is_deeply( Array::2D->slice( $empty_ref_to_slice, 1, 2, 1, 2 ),
    [], 'Fetched nonexistent slice from empty reference' );
is_deeply( $empty_ref_to_slice, [], "... and it's still empty" );

done_testing;
