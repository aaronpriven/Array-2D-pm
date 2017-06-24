use strict;
use warnings;

BEGIN {
    do './t/lib/testutil.pl' // do './lib/testutil.pl'
      // die "Can't load testutil.pl";
}

my $ins_ref = [ [ 'a', 1, 'x' ], [ 'b', 2, 'y' ], [ 'c', 3, 'z' ], ];

my %defaults = (
    ins_row     => { test_array => $ins_ref },
    ins_col     => { test_array => $ins_ref },
    push_row    => { test_array => $ins_ref },
    push_col    => { test_array => $ins_ref },
    unshift_row => { test_array => $ins_ref },
    unshift_col => { test_array => $ins_ref },
);

my @tests = (
    ins_row => [
        {   altered => [
                [ 'q', 'r', 's' ],
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ],
            expected => 4,
            description => 'Insert a row (top)',
            arguments   => [ 0,  'q', 'r', 's'  ]
        },
        {   arguments => [ 1,  'q', 'r', 's'  ],
            expected => 4,
            altered => [
                [ 'a', 1,   'x' ],
                [ 'q', 'r', 's' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ],
            description => 'Insert a row (middle)'
        },
        {   altered => [
                [ 'a', 1,   'x' ],
                [ 'q', 'r', 's' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ],
            expected => 4,
            description => 'Insert a row (negative index)',
            arguments   => [ -2,  'q', 'r', 's'  ]
        },
        {   description => 'Insert a row after the last one',
            altered    => [
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ],
                [ 'q', 'r', 's' ]
            ],
            expected => 4,
            arguments => [ 3,  'q', 'r', 's' ] ,
        },
        {   arguments => [ 4,  'q', 'r', 's'  ],
            description => 'Add a new row off the bottom',
            expected => 5,
            altered    => [
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                undef,
                [ 'q', 'r', 's' ]
            ]
        },
        {   altered => [
                [ 'a', 1, 'x' ],
                [ 'q', 'r' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ]
            ],
            expected => 4,
            description => 'Insert a shorter row',
            arguments   => [ 1,  'q', 'r'  ]
        },
        {   arguments => [ 1,  'q', undef, 's'  ],
            expected => 4,
            altered => [
                [ 'a', 1,     'x' ],
                [ 'q', undef, 's' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ]
            ],
            description => 'Insert a row with an undefined value'
        },
        {   arguments => [ 1,  'q', 'r', 's', 't'  ],
            description => 'Insert a longer row',
            expected => 4,
            altered    => [
                [ 'a', 1, 'x' ],
                [ 'q', 'r', 's', 't' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ]
        },
        {   test_array  => [],
            description => 'Insert row into an empty array',
            altered    => [ undef, [ 'q', 'r' ] ],
            arguments   => [ 1,  'q', 'r' ] ,
            expected => 2,
        },
        {   exception =>
              qr/Modification of non-creatable array value attempted/,
            arguments   => [ -5, 'New value' ],
            description => 'dies with invalid negative indices',
        },
    ],
    ins_col => [
        {   altered => [
                [ 'q', 'a', 1, 'x' ],
                [ 'r', 'b', 2, 'y' ],
                [ 's', 'c', 3, 'z' ]
            ],
            expected => 4,
            description => 'Insert a column (left)',
            arguments   => [ 0,  'q', 'r', 's'  ]
        },
        {   description => 'Insert a column (middle)',
            expected => 4,
            altered    => [
                [ 'a', 'q', 1, 'x' ],
                [ 'b', 'r', 2, 'y' ],
                [ 'c', 's', 3, 'z' ]
            ],
            arguments => [ 1,  'q', 'r', 's'  ]
        },
        {   arguments => [ -2,  'q', 'r', 's'  ],
            description => 'Insert a column (negative index)',
            expected => 4,
            altered    => [
                [ 'a', 'q', 1, 'x' ],
                [ 'b', 'r', 2, 'y' ],
                [ 'c', 's', 3, 'z' ]
            ]
        },
        {   altered => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', 's' ]
            ],
            expected => 4,
            description => 'Insert a column after the last one',
            arguments   => [ 3,  'q', 'r', 's'  ]
        },
        {   altered => [
                [ 'a', 1, 'x', undef, 'q' ],
                [ 'b', 2, 'y', undef, 'r' ],
                [ 'c', 3, 'z', undef, 's' ]
            ],
            expected => 5,
            description => 'Add a new column off the edge',
            arguments   => [ 4,  'q', 'r', 's'  ]
        },
        {   description => 'Insert a shorter column',
            altered    => [
                [ 'a', 'q',   1, 'x' ],
                [ 'b', 'r',   2, 'y' ],
                [ 'c', undef, 3, 'z' ]
            ],
            expected => 4,
            arguments => [ 1,  'q', 'r'  ]
        },
        {   arguments => [ 1,  'q', undef, 's'  ],
            expected => 4,
            altered => [
                [ 'a', 'q',   1, 'x' ],
                [ 'b', undef, 2, 'y' ],
                [ 'c', 's',   3, 'z' ]
            ],
            description => 'Insert a column with an undefined value'
        },
        {   description => 'Insert a longer column',
            expected => 4,
            altered    => [
                [ 'a',   'q', 1, 'x' ],
                [ 'b',   'r', 2, 'y' ],
                [ 'c',   's', 3, 'z' ],
                [ undef, 't' ]
            ],
            arguments => [ 1,  'q', 'r', 's', 't'  ]
        },
        {   arguments => [ 1,  'q', 'r' ] ,
            description => 'Insert column into an empty array',
            altered    => [ [ undef, 'q' ], [ undef, 'r' ] ],
            expected => 2,
            test_array  => []
        },
        {   exception =>
              qr/negative index off the beginning of the array/i,
            arguments   => [ -5, 'New value' ],
            description => 'dies with invalid negative indices',
        },
    ],
    push_row => [
        {   arguments => [  'q', 'r', 's' ] ,
            expected => 4,
            altered => [
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ],
                [ 'q', 'r', 's' ]
            ],
            description => 'Push a row'
        },
        {   altered => [
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                [ 'q', 'r' ]
            ],
            expected => 4,
            description => 'Push a shorter row',
            arguments   => [  'q', 'r' ] 
        },
        {   description => 'Push a row with an undefined value',
            altered    => [
                [ 'a', 1,     'x' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ],
                [ 'q', undef, 's' ]
            ],
            expected => 4,
            arguments => [  'q', undef, 's' ] 
        },
        {   arguments => [  'q', 'r', 's', 't' ] ,
            altered => [
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ],
                [ 'q', 'r', 's', 't' ]
            ],
            expected => 4,
            description => 'Push a longer row'
        },
        {   arguments =>  [ 'q', 'r' ] ,
            description => 'Push row into an empty array',
            altered    => [ [ 'q', 'r' ] ],
            expected => 1,
            test_array  => []
        }
    ],
    push_col => [
        {   arguments =>  [ 'q', 'r', 's' ] ,
            description => 'Push a column',
            expected => 4,
            altered    => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', 's' ]
            ]
        },
        {   description => 'Push a shorter column',
            expected => 4,
            altered    => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', 'r' ],
                [ 'c', 3, 'z', undef ]
            ],
            arguments =>  [ 'q', 'r' ] 
        },
        {   description => 'Push a column with an undefined value',
            altered    => [
                [ 'a', 1, 'x', 'q' ],
                [ 'b', 2, 'y', undef ],
                [ 'c', 3, 'z', 's' ]
            ],
            expected => 4,
            arguments =>  [ 'q', undef, 's' ] 
        },
        {   arguments =>  [ 'q', 'r', 's', 't' ] ,
            description => 'Push a longer column',
            expected => 4,
            altered    => [
                [ 'a',   1,     'x',   'q' ],
                [ 'b',   2,     'y',   'r' ],
                [ 'c',   3,     'z',   's' ],
                [ undef, undef, undef, 't' ]
            ]
        },
        {   test_array  => [],
            expected => 1,
            arguments   =>  [ 'q', 'r' ] ,
            altered    => [ ['q'], ['r'] ],
            description => 'Push column into an empty array'
        }
    ],
    unshift_col => [
        {   arguments =>  [ 'q', 'r', 's' ] ,
            description => 'Unshift a column',
            expected => 4,
            altered    => [
                [ 'q', 'a', 1, 'x' ],
                [ 'r', 'b', 2, 'y' ],
                [ 's', 'c', 3, 'z' ]
            ]
        },
        {   altered => [
                [ 'q',   'a', 1, 'x' ],
                [ 'r',   'b', 2, 'y' ],
                [ undef, 'c', 3, 'z' ]
            ],
            expected => 4,
            description => 'Unshift a shorter column',
            arguments   =>  [ 'q', 'r' ] 
        },
        {   arguments =>  [ 'q', undef, 's' ] ,
            expected => 4,
            altered => [
                [ 'q',   'a', 1, 'x' ],
                [ undef, 'b', 2, 'y' ],
                [ 's',   'c', 3, 'z' ]
            ],
            description => 'Unshift a column with an undefined value'
        },
        {   altered => [
                [ 'q', 'a', 1, 'x' ],
                [ 'r', 'b', 2, 'y' ],
                [ 's', 'c', 3, 'z' ],
                ['t']
            ],
            expected => 4,
            description => 'Unshift a longer column',
            arguments   =>  [ 'q', 'r', 's', 't' ] 
        },
        {   description => 'Unshift column into an empty array',
            expected => 1,
            altered    => [ ['q'], ['r'] ],
            arguments   =>  [ 'q', 'r' ] ,
            test_array  => []
        }
    ],
    unshift_row => [
        {   description => 'Unshift a row',
            expected => 4,
            altered    => [
                [ 'q', 'r', 's' ],
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ],
            arguments =>  [ 'q', 'r', 's' ] 
        },
        {   description => 'Unshift a shorter row',
            expected => 4,
            altered    => [
                [ 'q', 'r' ],
                [ 'a', 1, 'x' ],
                [ 'b', 2, 'y' ],
                [ 'c', 3, 'z' ]
            ],
            arguments =>  [ 'q', 'r' ] 
        },
        {   description => 'Unshift a row with an undefined value',
            expected => 4,
            altered    => [
                [ 'q', undef, 's' ],
                [ 'a', 1,     'x' ],
                [ 'b', 2,     'y' ],
                [ 'c', 3,     'z' ]
            ],
            arguments =>  [ 'q', undef, 's' ] 
        },
        {   altered => [
                [ 'q', 'r', 's', 't' ],
                [ 'a', 1,   'x' ],
                [ 'b', 2,   'y' ],
                [ 'c', 3,   'z' ]
            ],
            expected => 4,
            description => 'Unshift a longer row',
            arguments   =>  [ 'q', 'r', 's', 't' ] 
        },
        {   arguments =>  [ 'q', 'r' ] ,
            description => 'Unshift column into an empty array',
            expected => 1,
            altered    => [ [ 'q', 'r' ] ],
            test_array  => [],
        }
    ]
);

plan_and_run_generic_tests(\@tests, \%defaults);

__END__

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

done_testing;
