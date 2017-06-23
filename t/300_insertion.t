use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

my $ins_ref = [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ];

sub test_insertion {

    my $method = shift;
    my $test_r = shift;

    my @indices;
    @indices = @{ $test_r->{indices} } if exists $test_r->{indices};
    my $expected    = $test_r->{expected};
    my $description = $test_r->{description};
    my $test_array  = $test_r->{test_array} || $ins_ref;
    my @values      = @{ $test_r->{value} };

    my $obj_to_test = Array::2D->clone($test_array);
    my $ref_to_test = Array::2D->clone_unblessed($test_array);

    $obj_to_test->$method( @indices, @values );
    is_deeply( $obj_to_test, $expected, "$method: $description: object" );
    is_blessed($obj_to_test);

    Array::2D->$method( $ref_to_test, @indices, @values );
    is_deeply( $ref_to_test, $expected, "$method: $description: reference" );
    isnt_blessed($ref_to_test);
} ## tidy end: sub test_insertion

my %tests = (
    ins_row => [
        {   indices  => [0],
            expected => [
                [qw/q r s/],
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a row (top)',
        },
        {   indices  => [1],
            expected => [
                [ 'a', 1, 'x' ],
                [qw/q r s/],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a row (middle)'
        },
        {   indices  => [-2],
            expected => [
                [ 'a', 1, 'x' ],
                [ qw/q r s/, ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a row (negative index)'
        },
        {   indices  => [3],
            expected => [
                [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], [qw/q r s/]
            ],
            value       => [qw/q r s/],
            description => 'Insert a row after the last one'
        },
        {   indices  => [4],
            expected => [
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                undef,
                [qw/q r s/],
            ],
            value       => [qw/q r s/],
            description => 'Add a new row off the bottom',
        },
        {   indices => [1],
            expected =>
              [ [ 'a', 1, 'x' ], [qw/q r/], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ],
            value       => [qw/q r/],
            description => 'Insert a shorter row'
        },
        {   indices  => [1],
            expected => [
                [ 'a', 1,     'x' ],
                [ 'q', undef, 's' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ],
            ],
            value       => [ 'q', undef, 's' ],
            description => 'Insert a row with an undefined value'
        },
        {   indices  => [1],
            expected => [
                [ 'a', 1, 'x' ],
                [ qw/q r s t/, ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
            ],
            value       => [qw/q r s t/],
            description => 'Insert a longer row'
        },
        {   indices     => [1],
            expected    => [ undef, [qw/q r/] ],
            value       => [qw/q r/],
            description => 'Insert row into an empty array',
            test_array  => [],
        },
    ],
    ins_col => [
        {   indices  => [0],
            expected => [
                [ 'q', 'a', 1, 'x', ],
                [ 'r', 'b', 2, 'y' ],
                [ 's', 'c', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a column (left)'
        },
        {   indices  => [1],
            expected => [
                [ 'a', 'q', 1, 'x' ],
                [ 'b', 'r', 2, 'y' ],
                [ 'c', 's', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a column (middle)'
        },
        {   indices  => [-2],
            expected => [
                [ 'a', 'q', 1, 'x' ],
                [ 'b', 'r', 2, 'y' ],
                [ 'c', 's', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a column (negative index)'
        },
        {   indices  => [3],
            expected => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', 's' ],
            ],
            value       => [qw/q r s/],
            description => 'Insert a column after the last one'
        },
        {   indices  => [4],
            expected => [
                [ 'a', 1, 'x', undef, 'q' ],
                [ 'b', 2, 'y', undef, 'r' ],
                [ 'c', 3, 'z', undef, 's' ],
            ],
            value       => [qw/q r s/],
            description => 'Add a new column off the edge',
        },

        {   indices  => [1],
            expected => [
                [ 'a', 'q',   1, 'x' ],
                [ 'b', 'r',   2, 'y' ],
                [ 'c', undef, 3, 'z' ],
            ],
            value       => [qw/q r/],
            description => 'Insert a shorter column'
        },
        {   indices  => [1],
            expected => [
                [ 'a', 'q',   1, 'x' ],
                [ 'b', undef, 2, 'y' ],
                [ 'c', 's',   3, 'z' ],
            ],
            value => [ 'q', undef, 's' ],
            description => 'Insert a column with an undefined value'
        },
        {   indices  => [1],
            expected => [
                [ 'a',   'q', 1, 'x' ],
                [ 'b',   'r', 2, 'y' ],
                [ 'c',   's', 3, 'z' ],
                [ undef, 't' ],
            ],
            value       => [qw/q r s t/],
            description => 'Insert a longer column'
        },
        {   indices     => [1],
            expected    => [ [ undef, 'q' ], [ undef, 'r' ], ],
            value       => [qw/q r/],
            description => 'Insert column into an empty array',
            test_array  => [],
        },

    ],
    push_row => [

        {   expected => [
                [ 'a', 1, 'x', ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                [qw/q r s/],
            ],
            value       => [qw/q r s/],
            description => 'Push a row'
        },
        {   expected =>
              [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], [qw/q r/], ],
            value       => [qw/q r/],
            description => 'Push a shorter row'
        },
        {   expected => [
                [ 'a', 1,     'x' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ],
                [ 'q', undef, 's' ],
            ],
            value       => [ 'q', undef, 's' ],
            description => 'Push a row with an undefined value'
        },
        {   expected => [
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                [ 'q', 'r', 's', 't' ],
            ],
            value       => [qw/q r s t/],
            description => 'Push a longer row'
        },
        {   expected => [ [qw/q r/] ],
            value => [qw/q r/],
            description => 'Push row into an empty array',
            test_array  => [],
        },
    ],
    push_col => [

        {   expected => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', 's' ],
            ],
            value       => [qw/q r s/],
            description => 'Push a column'
        },
        {   expected => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', undef ],
            ],
            value       => [qw/q r/],
            description => 'Push a shorter column'
        },
        {   expected => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', undef, ],
                [ 'c', 3, 'z', 's' ],
            ],
            value       => [ 'q', undef, 's' ],
            description => 'Push a column with an undefined value'
        },
        {   expected => [
                [ 'a',   1,     'x',   'q' ],
                [ 'b',   2,     'y',   'r' ],
                [ 'c',   3,     'z',   's' ],
                [ undef, undef, undef, 't' ],
            ],
            value       => [qw/q r s t/],
            description => 'Push a longer column'
        },
        {   expected => [ ['q'], ['r'], ],
            value => [qw/q r/],
            description => 'Push column into an empty array',
            test_array  => [],
        },

    ],

    unshift_col => [
        {   expected => [
                [ 'q', 'a', 1, 'x', ],
                [ 'r', 'b', 2, 'y', ],
                [ 's', 'c', 3, 'z', ],
            ],
            value       => [qw/q r s/],
            description => 'Unshift a column'
        },
        {   expected => [
                [ 'q',   'a', 1, 'x', ],
                [ 'r',   'b', 2, 'y', ],
                [ undef, 'c', 3, 'z', ],
            ],
            value       => [qw/q r/],
            description => 'Unshift a shorter column'
        },
        {   expected => [
                [ 'q',   'a', 1, 'x', ],
                [ undef, 'b', 2, 'y' ],
                [ 's',   'c', 3, 'z', ],
            ],
            value => [ 'q', undef, 's' ],
            description => 'Unshift a column with an undefined value'
        },
        {   expected => [
                [ 'q', 'a', 1, 'x', ],
                [ 'r', 'b', 2, 'y', ],
                [ 's', 'c', 3, 'z', ],
                ['t'],
            ],
            value       => [qw/q r s t/],
            description => 'Unshift a longer column'
        },
        {   expected => [ ['q'], ['r'], ],
            value => [qw/q r/],
            description => 'Unshift column into an empty array',
            test_array  => [],
        },

    ],
    unshift_row => [

        {   expected => [
                [qw/q r s/],
                [ 'a', 1, 'x', ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
            ],
            value       => [qw/q r s/],
            description => 'Unshift a row'
        },
        {   expected =>
              [ [qw/q r/], [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ],
            value       => [qw/q r/],
            description => 'Unshift a shorter row'
        },
        {   expected => [
                [ 'q', undef, 's' ],
                [ 'a', 1,     'x' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ],
            ],
            value       => [ 'q', undef, 's' ],
            description => 'Unshift a row with an undefined value'
        },
        {   expected => [
                [ 'q', 'r', 's', 't' ],
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ],
            ],
            value       => [qw/q r s t/],
            description => 'Unshift a longer row'
        },
        {   expected => [ [qw/q r/] ],
            value => [qw/q r/],
            description => 'Unshift column into an empty array',
            test_array  => [],
        },
    ],
);

my %exception_tests = (
    ins_row => qr/Modification of non-creatable array value attempted/,
    ins_col => qr/negative index off the beginning of the array/,
);

my $test_count = 0;
foreach my $method ( keys %tests ) {
    $test_count += scalar @{ $tests{$method} };
}

plan( tests =>
      ( 12 + ( 4 * scalar keys %exception_tests ) + ( $test_count * 4 ) ) );

# four for each test, plus another 4 for the insert-die tests,
# plus 12, one for each method

foreach
  my $method (qw/ins_row ins_col push_row push_col unshift_row unshift_col/)
{
    a2dcan($method);

    for my $test_r ( @{ $tests{$method} } ) {
        test_insertion( $method, $test_r );
    }
    next if ( $method !~ /ins/ );

    my $ins_die_obj = Array::2D->clone($ins_ref);
    my $ins_die_ref = Array::2D->clone_unblessed($ins_ref);

    test_exception { $ins_die_obj->$method( -5, 'New value' ) }
    '$obj->' . "$method dies with invalid negative indices",
      $exception_tests{$method};

    test_exception {
        Array::2D->$method( $ins_die_ref, -5, ['New value'] )
    }
    $method . '($ref) dies with invalid negative indices',
      $exception_tests{$method};

} ## tidy end: foreach my $method (...)

foreach my $method (
    qw/ins_rows ins_cols push_rows push_cols unshift_rows unshift_cols/)
{
    a2dcan($method);
}

# all low priority

done_testing;
