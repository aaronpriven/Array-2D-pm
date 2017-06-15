use strict;
use Test::More 0.98;
use lib './lib';
use Array::2D;
use Scalar::Util(qw/blessed refaddr/);

our $sample_test = [
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       25, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'Vallejo' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0,  'San Francisco' ],
];

# $sample_test is the reference to which things are compared

our $sample_ref = [
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       25, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'Vallejo' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0,  'San Francisco' ],
];

# $sample_ref is used when testing class method invocation

our $sample_obj = Array::2D->new(
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       25, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'Vallejo' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0,  'San Francisco' ],
);
# $sample_obj is used when testing object invocation

our $sample_transposed_obj = Array::2D->new(
    [   'Joshua',  'Christopher', 'Emily',  'Nicholas',
        'Madison', 'Andrew',      'Hannah', 'Ashley',
        'Alexis',  'Joseph',
    ],
    [ 29, 59, 25, -14, 8, -15, 38, 57, 50, 0, ],
    [   'San Mateo',  'New York City', 'Dallas', undef,
        'Vallejo',    undef,           'Romita', 'Ray',
        'San Carlos', 'San Francisco',
    ],
    [ undef, undef, 'Aix-en-Provence' ],
    [   'Hannah', 'Alexis', 'Michael', undef,
        undef,    undef,    'Joshua',  undef,
        'Christopher'
    ],
);

our $sample_transposed_ref = [
    [   'Joshua',  'Christopher', 'Emily',  'Nicholas',
        'Madison', 'Andrew',      'Hannah', 'Ashley',
        'Alexis',  'Joseph',
    ],
    [ 29, 59, 25, -14, 8, -15, 38, 57, 50, 0, ],
    [   'San Mateo',  'New York City', 'Dallas', undef,
        'Vallejo',    undef,           'Romita', 'Ray',
        'San Carlos', 'San Francisco',
    ],
    [ undef, undef, 'Aix-en-Provence' ],
    [   'Hannah', 'Alexis', 'Michael', undef,
        undef,    undef,    'Joshua',  undef,
        'Christopher'
    ],
];

our $sample_transposed_test = [
    [   'Joshua',  'Christopher', 'Emily',  'Nicholas',
        'Madison', 'Andrew',      'Hannah', 'Ashley',
        'Alexis',  'Joseph',
    ],
    [ 29, 59, 25, -14, 8, -15, 38, 57, 50, 0, ],
    [   'San Mateo',  'New York City', 'Dallas', undef,
        'Vallejo',    undef,           'Romita', 'Ray',
        'San Carlos', 'San Francisco',
    ],
    [ undef, undef, 'Aix-en-Provence' ],
    [   'Hannah', 'Alexis', 'Michael', undef,
        undef,    undef,    'Joshua',  undef,
        'Christopher'
    ],
];

our $one_row_obj
  = Array::2D->new( [ 'Michael', 31, 'Union City', 'Vancouver', 'Emily' ], );

our $one_row_ref = [ [ 'Michael', 31, 'Union City', 'Vancouver', 'Emily' ], ];

our $one_col_ref = [
    ['Times'],  ['Helvetica'], ['Courier'], ['Lucida'],
    ['Myriad'], ['Minion'],    ['Syntax'],  ['Johnston'],
    ['Univers'], ['Frutiger'],
];

our $one_col_obj = Array::2D->new(
    ['Times'],  ['Helvetica'], ['Courier'], ['Lucida'],
    ['Myriad'], ['Minion'],    ['Syntax'],  ['Johnston'],
    ['Univers'], ['Frutiger'],
);

# $one_row_obj, $one_row_ref, $one_col_obj, $one_col_ref used for
# testing push, insert, etc.

our $empty_ref = [];
our $empty_obj = Array::2D->empty();

use Scalar::Util('blessed');

sub is_blessed {
    my $obj         = shift;
    my $description = shift;
    if ( defined $description ) {
        $description = "blessed correctly: $description";
    }
    else {
        $description = '... and result is blessed correctly';
    }
    is( blessed($obj), 'Array::2D', $description );
}

sub isnt_blessed {
    my $obj         = shift;
    my $description = shift;
    if ( defined $description ) {
        $description = "not blessed: $description";
    }
    else {
        $description = '... and result is not blessed';
    }
    is( blessed($obj), undef, $description );
}

sub a2dcan {
    can_ok( 'Array::2D', @_ );
}
