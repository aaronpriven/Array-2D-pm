use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $sample_obj,            $sample_ref,            $sample_test );
our ( $empty_obj,             $empty_ref );

plan tests => 219;

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
