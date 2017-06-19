use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $sample_ref,  $sample_transposed_ref );
our ( $one_row_ref, $one_row_test );
our ( $one_col_ref, $one_col_test );

my @all_tests = (
    {   indices      => [ 2, 3 ],
        test_against => [],
        description  => 'from empty array',
        test_array   => [],
    },
    {   indices      => [0],
        test_against => [ ['x'] ],
        description  => 'from one-element array',
        test_array   => [ ['x'] ],
    },
);

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
    {   indices => [8],
        test_against =>
          [ [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ] ],
        description => 'just one'
    },

);

my @rows_tests = (
    {   indices      => [0],
        test_against => [$one_row_test],
        description  => 'from one-row array',
        test_array   => $one_row_ref,
    },
    {   indices => [ 1, 2 ],
        test_against => [ ['Helvetica'], ['Courier'] ],
        description  => 'from one-column array',
        test_array   => $one_col_ref,
    },
);

my @cols_tests = (
    {   indices => [ 1, 2 ],
        test_against => [ [31], ['Union City'] ],
        description  => 'from one-row array',
        test_array   => $one_row_ref,
    },
    {   indices      => [0],
        test_against => [$one_col_test],
        description  => 'from one-column array',
        test_array   => $one_col_ref,
    },
);

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

plan(
    tests => (
        4 + ( @slice_tests * 10 ) + (
                @all_tests * 3
              + @rows_cols_tests * 2
              + @rows_tests
              + @cols_tests
              + @slice_cols_tests
        ) * 6
    )
);

sub test_multireader {
    my ( $method, $description, $indices, $expected_results, $test_array ) = @_;
    $test_array ||= $sample_ref;

    my $ref_to_test = Array::2D->clone_unblessed($test_array);
    my $obj_to_test = Array::2D->clone($test_array);

    my $obj_result = $obj_to_test->$method(@$indices);
    is_deeply( $obj_result, $expected_results, "$description: object" );
    is_deeply( $obj_to_test, $test_array,
        '... and it did not alter the object' );
    is_blessed($obj_result);

    my $ref_result = Array::2D->$method( $ref_to_test, @$indices );
    is_deeply( $ref_result, $expected_results, "$description: reference" );
    is_deeply( $ref_to_test, $test_array,
        '... and it did not alter the reference' );
    is_blessed($ref_result);

} ## tidy end: sub test_multireader

a2dcan('rows');

for my $test_r ( @all_tests, @rows_cols_tests, @rows_tests ) {
    my $indices          = $test_r->{indices};
    my $expected_results = $test_r->{test_against};
    my $description      = $test_r->{description};
    my $test_array       = $test_r->{test_array};

    test_multireader( 'rows', "Fetched rows: $description",
        $indices, $expected_results, $test_array );

}

a2dcan('cols');

for my $test_r ( @all_tests, @rows_cols_tests, @cols_tests ) {
    my $indices          = $test_r->{indices};
    my $expected_results = $test_r->{test_against};
    my $description      = $test_r->{description};
    my $test_array       = $test_r->{test_array} || $sample_transposed_ref;

    test_multireader( 'cols', "Fetched cols: $description",
        $indices, $expected_results, $test_array );

}

a2dcan('slice_cols');

for my $test_r ( @all_tests, @slice_cols_tests ) {
    my $indices          = $test_r->{indices};
    my $expected_results = $test_r->{test_against};
    my $description      = $test_r->{description};
    my $test_array       = $test_r->{test_array};

    test_multireader( 'slice_cols', "Fetched sliced cols: $description",
        $indices, $expected_results, $test_array );

}

a2dcan('slice');

for my $test_r (@slice_tests) {
    my $indices          = $test_r->{indices};
    my $expected_results = $test_r->{test_against};
    my $description      = $test_r->{description};
    my $test_array       = $test_r->{test_array};

    test_multireader( 'slice', "Fetched slice: $description",
        $indices, $expected_results, $test_array );

    my $obj_to_test = Array::2D->clone($sample_ref);
    $obj_to_test->slice(@$indices);
    is_deeply( $obj_to_test,
        $expected_results, "Sliced in place: $description: object" );
    is_blessed($obj_to_test);

    my $ref_to_test = Array::2D->clone_unblessed($sample_ref);
    Array::2D->slice( $ref_to_test, @$indices );
    is_deeply( $ref_to_test,
        $expected_results, "Sliced in place: $description: reference" );
    isnt_blessed($ref_to_test);

} ## tidy end: for my $test_r (@slice_tests)

done_testing;
