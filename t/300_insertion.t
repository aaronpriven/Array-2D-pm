use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

use Test::Fatal;

my $ins_ref = [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ];

note 'Testing ins_row()';
a2dcan('ins_row');
# low priority

note 'Testing ins_col()';
a2dcan('ins_col');
# high priority

my @ins_col_tests = (
    {   indices      => [0],
        test_against => [
            [ 'q', 'a', 1, 'x', ], [ 'r', 'b', 2, 'y' ], [ 's', 'c', 3, 'z' ],
        ],
        value       => [qw/q r s/],
        description => 'Insert a column (left)'
    },
    {   indices => [1],
        test_against =>
          [ [ 'a', 'q', 1, 'x' ], [ 'b', 'r', 2, 'y' ], [ 'c', 's', 3, 'z' ], ],
        value       => [qw/q r s/],
        description => 'Insert a column (middle)'
    },
    {   indices => [-2],
        test_against =>
          [ [ 'a', 'q', 1, 'x' ], [ 'b', 'r', 2, 'y' ], [ 'c', 's', 3, 'z' ], ],
        value       => [qw/q r s/],
        description => 'Insert a column (negative index)'
    },
    {   indices => [3],
        test_against =>
          [ [ 'a', 1, 'x', 'q' ], [ 'b', 2, 'y', 'r' ], [ 'c', 3, 'z', 's' ], ],
        value       => [qw/q r s/],
        description => 'Insert a column after the last one'
    },
    {   indices      => [4],
        test_against => [
            [ 'a', 1, 'x', undef, 'q' ],
            [ 'b', 2, 'y', undef, 'r' ],
            [ 'c', 3, 'z', undef, 's' ],
        ],
        value       => [qw/q r s/],
        description => 'Add a new column off the edge',
    },

    {   indices      => [1],
        test_against => [
            [ 'a', 'q',   1, 'x' ],
            [ 'b', 'r',   2, 'y' ],
            [ 'c', undef, 3, 'z' ],
        ],
        value       => [qw/q r/],
        description => 'Insert a shorter column'
    },
    {   indices      => [1],
        test_against => [
            [ 'a', 'q',   1, 'x' ],
            [ 'b', undef, 2, 'y' ],
            [ 'c', 's',   3, 'z' ],
        ],
        value       => [ 'q', undef, 's' ],
        description => 'Insert a column with an undefined value'
    },
    {   indices      => [1],
        test_against => [
            [ 'a',   'q', 1, 'x' ],
            [ 'b',   'r', 2, 'y' ],
            [ 'c',   's', 3, 'z' ],
            [ undef, 't' ],
        ],
        value       => [qw/q r s t/],
        description => 'Insert a longer column'
    },

);

for my $test_r (@ins_col_tests) {
    my $idx          = ${ $test_r->{indices} }[0];
    my $test_against = $test_r->{test_against};
    my $description  = $test_r->{description};
    my @values       = @{ $test_r->{value} };

    my $sample_obj = Array::2D->clone($ins_ref);
    my $sample_ref = Array::2D->clone_unblessed($ins_ref);

    $sample_obj->ins_col( $idx, @values );
    is_deeply( $sample_obj,
        $test_against, "ins_col: $description: sample object" );
    is_blessed($sample_obj);

    Array::2D->ins_col( $sample_ref, $idx, @values );
    is_deeply( $sample_ref,
        $test_against, "ins_col: $description: sample reference" );
    isnt_blessed($sample_ref);
}

{

    my $empty_obj = Array::2D->empty;
    $empty_obj->ins_col( 1, qw/q r/ );
    is_deeply(
        $empty_obj,
        [ [ undef, 'q' ], [ undef, 'r' ], ],
        'ins_col: into empty obj'
    );
    is_blessed($empty_obj);

    my $empty_ref = [];
    Array::2D->ins_col( $empty_ref, 1, qw/q r/ );
    is_deeply(
        $empty_ref,
        [ [ undef, 'q' ], [ undef, 'r' ] ],
        'ins_col: into empty ref'
    );
    isnt_blessed($empty_ref);

    my $sample_die_obj = Array::2D->clone($ins_ref);
    my $sample_die_ref = Array::2D->clone_unblessed($ins_ref);

    my $exception_obj
      = exception( sub { $sample_die_obj->ins_col( -5, 'New value' ) } );

    isnt( $exception_obj, undef,
        '$obj->ins_col dies with invalid negative indices' );
    like(
        $exception_obj,
        qr/negative index off the beginning of the array/,

        "... and it's the expected exception",
    );

    my $exception_ref
      = exception(
        sub { Array::2D->ins_col( $sample_die_ref, -5, ['New value'] ) } );
    isnt( $exception_ref, undef,
        'ins_col($ref) dies with invalid negative indices' );
    like(
        $exception_ref,
        qr/negative index off the beginning of the array/,
        "... and it's the expected exception",
    );
}

note 'Testing ins_rows()';
a2dcan('ins_rows');
# low

note 'Testing ins_cols()';
a2dcan('ins_cols');
#low

note 'Testing push_row()';
a2dcan('push_row');
# high

note 'Testing push_col()';
a2dcan('push_col');
# high

note 'Testing push_rows()';
a2dcan('push_rows');
# low

note 'Testing push_cols()';
a2dcan('push_cols');
# low

note 'Testing unshift_row()';
a2dcan('unshift_row');
# high

note 'Testing unshift_col()';
a2dcan('unshift_col');
# low

note 'Testing unshift_rows()';
a2dcan('unshift_rows');
#low

note 'Testing unshift_cols()';
a2dcan('unshift_cols');
# low

done_testing;
