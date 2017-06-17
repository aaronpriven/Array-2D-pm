use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

use Test::Fatal;

my $set_ref = [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ];

note 'Testing set_element()';
a2dcan('set_element');

my @element_tests = (
    {   indices => [ 0, 0 ],
        test_against =>
          [ [ 'New value', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ],
        value       => 'New value',
        description => 'Replace a value (top left)'
    },
    {   indices => [ 2, 2 ],
        test_against =>
          [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'New value' ], ],
        value       => 'New value',
        description => 'Replace a value (bottom right)'
    },
    {   indices => [ 1, 1 ],
        test_against =>
          [ [ 'a', 1, 'x' ], [ 'b', 'New value', 'y' ], [ 'c', 3, 'z' ], ],
        value       => 'New value',
        description => 'Replace a value (middle)'
    },
    {   indices      => [ 1, 4 ],
        test_against => [
            [ 'a', 1, 'x' ],
            [ 'b', 2, 'y', undef, 'New value' ],
            [ 'c', 3, 'z' ],
        ],
        value       => 'New value',
        description => 'Add a new value off the array to the right'
    },
    {   indices      => [ 4, 1 ],
        test_against => [
            [ 'a', 1, 'x' ],
            [ 'b', 2, 'y' ],
            [ 'c', 3, 'z' ],
            undef,
            [ undef, 'New value' ]
        ],
        value       => 'New value',
        description => 'Add a new value off the array to the bottom'
    },
    {   indices      => [ 4, 4 ],
        test_against => [
            [ 'a', 1, 'x' ],
            [ 'b', 2, 'y' ],
            [ 'c', 3, 'z' ],
            undef, [ undef, undef, undef, undef, 'New value' ]
        ],
        value       => 'New value',
        description => 'Add a new value off the array to the bottom and right'
    },
);

for my $test_r (@element_tests) {
    my @indices      = @{ $test_r->{indices} };
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};
    my $value        = $test_r->{value};

    # we already tested cloning, so this should be ok

    my $sample_obj = Array::2D->clone($set_ref);
    my $sample_ref = Array::2D->clone_unblessed($set_ref);

    $sample_obj->set_element( @indices, $value );

    is_deeply( $sample_obj,
        $test_against, "Set element: $description: sample object" );
    is_blessed($sample_obj);

    Array::2D->set_element( $sample_ref, @indices, $value );
    is_deeply( $sample_ref,
        $test_against, "Set element: $description: sample reference" );
    isnt_blessed($sample_ref);

    #note explain $sample_ref;

} ## tidy end: for my $test_r (@element_tests)

my @element_die_tests = (
    { indices => [ 0,  -4 ], description => 'left' },
    { indices => [ -4, 0 ],  description => 'top' },
    { indices => [ -4, -4 ], description => 'top and left' },
);

for my $test_r (@element_die_tests) {
    my @indices     = @{ $test_r->{indices} };
    my $description = $test_r->{description};

    my $sample_obj = Array::2D->empty;
    my $sample_ref = [];

    my $exception_obj
      = exception( sub { $sample_obj->set_element( @indices, 'New value' ) } );
    isnt(
        $exception_obj,
        undef,
        '$obj->set_element dies with invalid negative indices to the '
          . $description,
    );
    like(
        $exception_obj,
        qr/Modification of non-creatable array value/,
        "... and it's the expected exception",
    );

    my $exception_ref
      = exception(
        sub { Array::2D->set_element( $sample_ref, @indices, 'New value' ) } );
    isnt(
        $exception_ref,
        undef,
        'set_element($ref) dies invalid negative indices to the '
          . $description,
    );
    like(
        $exception_ref,
        qr/Modification of non-creatable array value/,
        "... and it's the expected exception",
    );
} ## tidy end: for my $test_r (@element_die_tests)

my @set_row_tests = (
    {   indices => [0],
        test_against =>
          [ [ 'q', 'r', 's' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ],
        value       => [qw/q r s/],
        description => 'Replace a row (top)'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 1, 'x' ], [ 'q', 'r', 's' ], [ 'c', 3, 'z' ], ],
        value       => [qw/q r s/],
        description => 'Replace a row (middle)'
    },
    {   indices => [-2],
        test_against =>
          [ [ 'a', 1, 'x' ], [ 'q', 'r', 's' ], [ 'c', 3, 'z' ], ],
        value       => [qw/q r s/],
        description => 'Replace a row (negative index)'
    },
    {   indices      => [2],
        test_against => [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [qw/q r s/], ],
        value        => [qw/q r s/],
        description  => 'Replace a row (final row)'
    },
    {   indices      => [3],
        test_against => [
            [ 'a', 1,   'x' ],
            [ 'b', 2,   'y' ],
            [ 'c', 3,   'z' ],
            [ 'q', 'r', 's' ],
        ],
        value       => [qw/q r s/],
        description => 'Add a new row at the bottom'
    },
    {   indices      => [4],
        test_against => [
            [ 'a', 1, 'x' ],
            [ 'b', 2, 'y' ],
            [ 'c', 3, 'z' ],
            undef,
            [qw/q r s/]
        ],
        value       => [qw/q r s/],
        description => 'Add a new value below the bottom'
    },
    {   indices      => [1],
        test_against => [ [ 'a', 1, 'x' ], [ 'q', 'r' ], [ 'c', 3, 'z' ], ],
        value        => [qw/q r/],
        description  => 'Replace a row with a shorter row'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 1, 'x' ], [ 'q', undef, 's' ], [ 'c', 3, 'z' ], ],
        value => [ 'q', undef, 's' ],
        description => 'Replace a row with one with an undefined value'
    },
    {   indices      => [1],
        test_against => [ [ 'a', 1, 'x' ], [qw/q r s t/], [ 'c', 3, 'z' ], ],
        value        => [qw/q r s t/],
        description  => 'Replace a row with a longer row'
    },

);

note "Testing set_row()";
a2dcan('set_row');

for my $test_r (@set_row_tests) {
    my $idx          = ${ $test_r->{indices} }[0];
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};
    my @values       = @{ $test_r->{value} };

    my $sample_obj = Array::2D->clone($set_ref);
    my $sample_ref = Array::2D->clone_unblessed($set_ref);

    $sample_obj->set_row( $idx, @values );
    is_deeply( $sample_obj,
        $test_against, "set_row: $description: sample object" );
    is_blessed($sample_obj);

    Array::2D->set_row( $sample_ref, $idx, @values );
    is_deeply( $sample_ref,
        $test_against, "set_row: $description: sample reference" );
    isnt_blessed($sample_ref);
}

my $sample_die_obj = Array::2D->clone($set_ref);
my $sample_die_ref = Array::2D->clone_unblessed($set_ref);

my $exception_obj
  = exception( sub { $sample_die_obj->set_row( -5, ['New value'] ) } );

isnt( $exception_obj, undef,
    '$obj->set_row dies with invalid negative indices' );
like(
    $exception_obj,
    qr/Modification of non-creatable array value/,
    "... and it's the expected exception",
);

my $exception_ref
  = exception( sub { Array::2D->set_row( $sample_die_ref, -5, ['New value'] ) }
  );
isnt( $exception_ref, undef,
    'set_row($ref) dies with invalid negative indices' );
like(
    $exception_ref,
    qr/Modification of non-creatable array value/,
    "... and it's the expected exception",
);

my @set_col_tests = (
    {   indices      => [0],
        test_against => [ [ 'q', 1, 'x' ], [ 'r', 2, 'y' ], [ 's', 3, 'z' ], ],
        value        => [qw/q r s/],
        description  => 'Replace a column (left)'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', 'r', 'y' ], [ 'c', 's', 'z' ], ],
        value       => [qw/q r s/],
        description => 'Replace a column (middle)'
    },
    {   indices => [-2],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', 'r', 'y' ], [ 'c', 's', 'z' ], ],
        value       => [qw/q r s/],
        description => 'Replace a column (negative index)'
    },
    {   indices      => [2],
        test_against => [ [ 'a', 1, 'q' ], [ 'b', 2, 'r' ], [ 'c', 3, 's' ], ],
        value        => [qw/q r s/],
        description  => 'Replace a column (final column)'
    },
    {   indices => [3],
        test_against =>
          [ [ 'a', 1, 'x', 'q' ], [ 'b', 2, 'y', 'r' ], [ 'c', 3, 'z', 's' ], ],
        value       => [qw/q r s/],
        description => 'Add a new column at the right'
    },
    {   indices      => [4],
        test_against => [
            [ 'a', 1, 'x', undef, 'q' ],
            [ 'b', 2, 'y', undef, 'r' ],
            [ 'c', 3, 'z', undef, 's' ],
        ],
        value       => [qw/q r s/],
        description => 'Add a new value below the right'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', 'r', 'y' ], [ 'c', undef, 'z' ], ],
        value       => [qw/q r/],
        description => 'Replace a column with a shorter column'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', undef, 'y' ], [ 'c', 's', 'z' ], ],
        value => [ 'q', undef, 's' ],
        description => 'Replace a column with one with an undefined value'
    },
    {   indices      => [1],
        test_against => [
            [ 'a',   'q', 'x' ],
            [ 'b',   'r', 'y' ],
            [ 'c',   's', 'z' ],
            [ undef, 't' ],
        ],
        value       => [qw/q r s t/],
        description => 'Replace a column with a longer column'
    },

    {   indices => [-2],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', 'r', 'y' ], [ 'c', undef, 'z' ], ],
        value       => [qw/q r/],
        description => 'Replace a column with a shorter column (negative index)'
    },
    {   indices => [-2],
        test_against =>
          [ [ 'a', 'q', 'x' ], [ 'b', undef, 'y' ], [ 'c', 's', 'z' ], ],
        value => [ 'q', undef, 's' ],
        description =>
          'Replace column with one with undefined value (negative index)'
    },
    {   indices      => [-2],
        test_against => [
            [ 'a',   'q', 'x' ],
            [ 'b',   'r', 'y' ],
            [ 'c',   's', 'z' ],
            [ undef, 't' ],
        ],
        value       => [qw/q r s t/],
        description => 'Replace a column with a longer column (negative index)'
    },
);

note "Testing set_col()";
a2dcan('set_col');

for my $test_r (@set_col_tests) {
    my $idx          = ${ $test_r->{indices} }[0];
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};
    my @values       = @{ $test_r->{value} };

    my $sample_obj = Array::2D->clone($set_ref);
    my $sample_ref = Array::2D->clone_unblessed($set_ref);

    $sample_obj->set_col( $idx, @values );
    is_deeply( $sample_obj,
        $test_against, "set_col: $description: sample object" );
    is_blessed($sample_obj);

    Array::2D->set_col( $sample_ref, $idx, @values );
    is_deeply( $sample_ref,
        $test_against, "set_col: $description: sample reference" );
    isnt_blessed($sample_ref);
}

{
    my $sample_die_obj = Array::2D->clone($set_ref);
    my $sample_die_ref = Array::2D->clone_unblessed($set_ref);

    my $exception_obj
      = exception( sub { $sample_die_obj->set_col( -5, ['New value'] ) } );

    isnt( $exception_obj, undef,
        '$obj->set_col dies with invalid negative indices' );
    like(
        $exception_obj,
        qr/negative index off the beginning of the array/,
        "... and it's the expected exception",
    );

    my $exception_ref
      = exception(
        sub { Array::2D->set_col( $sample_die_ref, -5, ['New value'] ) } );
    isnt( $exception_ref, undef,
        'set_col($ref) dies with invalid negative indices' );
    like(
        $exception_ref,
        qr/negative index off the beginning of the array/,
        "... and it's the expected exception",
    );
}

note 'Testing set_rows()';
a2dcan('set_rows');
# low priority

note 'Testing set_cols()';
a2dcan('set_cols');
# low priority

note 'Testing set_slice()';
a2dcan('set_slice');
# low priority

done_testing;
