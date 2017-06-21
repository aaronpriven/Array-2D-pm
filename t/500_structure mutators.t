use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $one_row_ref, $one_col_ref );

a2dcan('transpose');
# low

a2dcan('flattened');
# high

my @tests = (
    {   test_array => [ [qw/a b c/], [ 1, 2, 3, ], [qw/x y z/] ],
        flat        => [ qw/a b c/, 1, 2, 3, qw/x y z/ ],
        description => 'flatten rectangular array',
    },
    {   test_array =>
          [ [ undef, qw/b c/ ], [ 1, 2, 3, 4, ], [qw/x y z/], ['q'], ],
        flat        => [ qw/b c/, 1, 2, 3, 4,, qw/x y z/, 'q', ],
        description => 'flatten ragged array',
    },
    {   test_array  => $one_row_ref,
        flat        => [ 'Michael', 31, 'Union City', 'Vancouver', 'Emily' ],
        description => 'flatten one-row array',
    },
    {   test_array => $one_col_ref,
        flat       => [
            qw/Times Helvetica Courier Lucida Myriad
              Minion Syntax Johnston Univers Frutiger/
        ],
        description => 'flatten one-column array',
    },

);

foreach my $test_r (@tests) {

    my $expected    = $test_r->{flat};
    my $description = $test_r->{description};
    my $test_array  = $test_r->{test_array};

    my $obj_to_test = Array::2D->clone($test_array);
    my $ref_to_test = Array::2D->clone_unblessed($test_array);

    my @obj_returned = $obj_to_test->flattened;

    is_deeply( \@obj_returned, $expected, "$description: object" );

    my @ref_returned = Array::2D->flattened($ref_to_test);
    is_deeply( \@ref_returned, $expected, "$description: ref" );

}

done_testing;
