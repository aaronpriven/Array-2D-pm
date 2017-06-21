use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

my $del_row_ref
  = [ [ 'a', 1, 'w' ], [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ];

my $del_col_ref = [ [qw/a b c d/], [ 1, 2, 3, 4 ], [qw/w x y z/], ];

sub test_deletion {

    my $method = shift;
    my $test_r = shift;

    my @indices;
    @indices = @{ $test_r->{indices} } if exists $test_r->{indices};
    my $expected    = $test_r->{expected};
    my $description = $test_r->{description};
    my $test_array  = $test_r->{test_array} || $del_row_ref;
    my $remain      = $test_r->{remain};

    my $obj_to_test = Array::2D->clone($test_array);
    my $ref_to_test = Array::2D->clone_unblessed($test_array);

    my @obj_returned = $obj_to_test->$method(@indices);
    is_deeply( \@obj_returned, $expected, "$method: $description: object" );
    is_deeply( $obj_to_test, $remain,
        "... and remaining values are as expected" );
    is_blessed($obj_to_test);

    my @ref_returned = Array::2D->$method( $ref_to_test, @indices );
    is_deeply( \@ref_returned, $expected, "$method: $description: ref" );
    is_deeply(
        $ref_to_test, $remain,
        "... and remaining values are as expected"
    );
    isnt_blessed($ref_to_test);
} ## tidy end: sub test_deletion

my %tests = (
    del_row => [
        {   indices  => [0],
            expected => [ 'a', 1, 'w' ],
            remain   => [ [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'delete first row',
            test_array  => $del_row_ref,
        },
        {   indices  => [1],
            expected => [ 'b', 2, 'x' ],
            remain   => [ [ 'a', 1, 'w' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'delete middle row',
            test_array  => $del_row_ref,
        },
        {   indices  => [4],
            expected => [ 'd', 4, 'z' ],
            remain   => [ [ 'a', 1, 'w' ], [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], ],
            description => 'delete last row',
            test_array  => $del_row_ref,
        },
        {   indices  => [-2],
            expected => [ 'c', 3, 'y' ],
            remain   => [ [ 'a', 1, 'w' ], [ 'b', 2, 'x' ], [ 'd', 4, 'z' ], ],
            description => 'delete row (negative index)',
            test_array  => $del_row_ref,
        },
        {   indices     => [5],
            expected    => [],
            remain      => Array::2D->clone_unblessed($del_row_ref),
            description => 'delete row (off end of array)',
            test_array  => Array::2D->clone_unblessed($del_row_ref),
        },
        {   indices     => [1],
            expected    => [],
            remain      => [],
            description => 'delete row from empty array',
            test_array  => [],
        },
        {   indices  => [1],
            expected => [ 'b', 2 ],
            remain   => [ [ 'a', 1, 'w' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'delete short row',
            test_array  => [
                [ 'a', 1, 'w' ], [ 'b', 2 ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ],
            ]
        },
        {   indices  => [1],
            expected => [ 'b', 2, 'x', 9 ],
            remain   => [ [ 'a', 1, 'w' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'delete long row',
            test_array  => [
                [ 'a', 1, 'w' ],
                [ 'b', 2, 'x', 9 ],
                [ 'c', 3, 'y' ],
                [ 'd', 4, 'z' ],
            ]
        },
        {   indices  => [1],
            expected => [ 'b', undef, 'x' ],
            remain   => [ [ 'a', 1, 'w' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'delete row with undefined value',
            test_array  => [
                [ 'a', 1,     'w' ],
                [ 'b', undef, 'x' ],
                [ 'c', 3,     'y' ],
                [ 'd', 4,     'z' ],
            ]
        },
    ],
    del_col => [
        {   indices     => [0],
            expected    => [ 'a', 1, 'w' ],
            remain      => [ [qw/b c d/], [ 2, 3, 4 ], [qw/x y z/], ],
            description => 'delete first col',
            test_array  => $del_col_ref,
        },
        {   indices     => [1],
            expected    => [ 'b', 2, 'x' ],
            remain      => [ [qw/a c d/], [ 1, 3, 4 ], [qw/w y z/], ],
            description => 'delete middle column',
            test_array  => $del_col_ref,
        },
        {   indices     => [4],
            expected    => [ 'd', 4, 'z' ],
            remain      => [ [qw/a b c/], [ 1, 2, 3, ], [qw/w x y/], ],
            description => 'delete last column',
            test_array  => $del_col_ref,
        },
        {   indices     => [-2],
            expected    => [ 'c', 3, 'y' ],
            remain      => [ [qw/a b c d/], [ 1, 2, 3, 4 ], [qw/w x y z/], ],
            description => 'delete column (negative index)',
            test_array  => $del_col_ref,
        },
        {   indices     => [5],
            expected    => [],
            remain      => Array::2D->clone_unblessed($del_col_ref),
            description => 'delete column (off end of array)',
            test_array  => Array::2D->clone_unblessed($del_col_ref),
        },
        {   indices     => [1],
            expected    => [],
            remain      => [],
            description => 'delete column from empty array',
            test_array  => [],
        },
        {   indices     => [1],
            expected    => [ 'b', 2 ],
            remain      => [ [qw/a c d/], [ 1, 3, 4 ], [qw/w y z/], ],
            description => 'delete short column',
            test_array =>
              [ [qw/a b c d/], [ 1, 2, 3, 4 ], [ 'w', undef, qw/y z/ ], ],
        },
        {   indices     => [1],
            expected    => [ 'b', 2, 'x', 9 ],
            remain      => [ [qw/a c d/], [ 1, 3, 4 ], [qw/w y z/], ],
            description => 'delete long column',
            test_array =>
              [ [qw/a b c d/], [ 1, 2, 3, 4 ], [qw/w x y z/], [ undef, 9 ], ],

        },
        {   indices     => [1],
            expected    => [ 'b', undef, 'x' ],
            remain      => [ [qw/a c d/], [ 1, 3, 4 ], [qw/w y z/], ],
            description => 'delete column with undefined value',
            test_array => [ [qw/a b c d/], [ 1, undef, 3, 4 ], [qw/w x y z/], ],
        },
    ],
    shift_row => [
        {   expected => [ 'a', 1, 'w' ],
            remain => [ [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'shift first row',
            test_array  => $del_row_ref,
        },
        {   expected    => [],
            remain      => [],
            description => 'shift row from empty array',
            test_array  => [],
        },
        {   indices     => [1],
            expected    => [ 'a', 1 ],
            remain      => [ [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'shift short row',
            test_array  => [
                [ 'a', 1 ], [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ],
            ]
        },
        {   indices  => [1],
            expected => [ 'a', 1, 'w', 9 ],
            remain   => [ [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'shift long row',
            test_array  => [
                [ 'a', 1, 'w', 9 ],
                [ 'b', 2, 'x' ],
                [ 'c', 3, 'y' ],
                [ 'd', 4, 'z' ],
            ]
        },
        {   indices  => [1],
            expected => [ 'a', undef, 'w' ],
            remain   => [ [ 'b', 2, 'x' ], [ 'c', 3, 'y' ], [ 'd', 4, 'z' ], ],
            description => 'shift row with undefined value',
            test_array  => [
                [ 'a', undef, 'w' ],
                [ 'b', 2,     'x' ],
                [ 'c', 3,     'y' ],
                [ 'd', 4,     'z' ],
            ]
        },
    ],
    shift_col => [],
    pop_row   => [],
    pop_col   => [],
);

my %exception_tests = (
    del_row => qr/Modification of non-creatable array value attempted/,
    del_col => qr/negative index off the beginning of the array/,
);

foreach my $method (qw/del_row del_col pop_row pop_col shift_row shift_col/) {
    a2dcan($method);

    for my $test_r ( @{ $tests{$method} } ) {
        test_deletion( $method, $test_r );
    }
    next if ( $method !~ /del/ );

    my $del_die_obj = Array::2D->clone($del_row_ref);
    my $del_die_ref = Array::2D->clone_unblessed($del_row_ref);

    test_exception { $del_die_obj->$method(-5) }
    '$obj->' . "$method dies with invalid negative indices",
      $exception_tests{$method};

    test_exception { Array::2D->$method( $del_die_ref, -5 ) }
    $method . '($ref) dies with invalid negative indices',
      $exception_tests{$method};

} ## tidy end: foreach my $method (...)

a2dcan('del_row');
# low

a2dcan('del_col');
# low

a2dcan('shift_row');
# high

a2dcan('shift_col');
# low

a2dcan('pop_row');
# low

a2dcan('pop_col');
# low

a2dcan('del_rows');
# low

a2dcan('del_cols');
# low

done_testing;
