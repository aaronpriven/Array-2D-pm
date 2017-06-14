use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $sample_obj,            $sample_ref,            $sample_test );
our ( $sample_transposed_obj, $sample_transposed_ref, $sample_transposed_test );
our ( $empty_obj, $empty_ref );

#our ( $one_row_obj, $one_row_ref, $one_col_obj, $one_col_ref );

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

note 'Testing rows() and cols()';
a2dcan('rows');
a2dcan('cols');

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
    {   indices      => [ 4, 5 ],
        test_against => [
            [ 'Madison', 8, 'Vallejo' ],
            [ 'Andrew',  -15, ],

        ],
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

);

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
    
    
    my $sample_transposed_obj_result = $sample_transposed_obj->cols(@indices);
    is_deeply( $sample_transposed_obj_result,
        $test_against, "Fetched cols: $description: sample object" );
    is_deeply( $sample_transposed_obj, $sample_transposed_test,
        '... and it did not alter the object' );
    is_blessed($sample_transposed_obj_result);

    my $sample_transposed_ref_result = Array::2D->rows( $sample_ref, @indices );
    is_deeply( $sample_transposed_ref_result,
        $test_against, "Fetched cols: $description: sample reference" );
    is_deeply( $sample_transposed_ref, $sample_transposed_test,
        '... and it did not alter the reference' );
    is_blessed($sample_transposed_ref_result);

} ## tidy end: for my $test_r (@rows_cols_tests)

note 'Testing slice()';
a2dcan('slice');

done_testing;
