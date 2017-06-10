our $sample_test = [
    [ 'Michael',     31, 'San Mateo',     'Vancouver',       'Emily' ],
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       31, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'San Francisco' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0, undef, 'San Francisco' ],
];

# $sample_test is the reference to which things are compared

our $sample_ref = [
    [ 'Michael',     31, 'San Mateo',     'Vancouver',       'Emily' ],
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       31, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'San Francisco' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0, undef, 'San Francisco' ],
];

# $sample_ref is used when testing class method invocation

our $sample_obj = Array::2D->new(
    [ 'Michael',     31, 'San Mateo',     'Vancouver',       'Emily' ],
    [ 'Joshua',      29, 'San Mateo',     undef,             'Hannah' ],
    [ 'Christopher', 59, 'New York City', undef,             'Alexis' ],
    [ 'Emily',       31, 'Dallas',        'Aix-en-Provence', 'Michael' ],
    [ 'Nicholas',    -14, ],
    [ 'Madison', 8, 'San Francisco' ],
    [ 'Andrew',  -15, ],
    [ 'Hannah', 38, 'Romita',     undef, 'Joshua', ],
    [ 'Ashley', 57, 'Ray' ],
    [ 'Alexis', 50, 'San Carlos', undef, 'Christopher' ],
    [ 'Joseph', 0, undef, 'San Francisco' ],
);

use Scalar::Util('blessed');

sub is_blessed {
    my $obj         = shift;
    my $description = shift // q[];
    is (blessed($obj), 'Array::2D', "blessed correctly: $description" );
}

sub isnt_blessed {
   my $obj = shift;
   my $description = shift // q[];
   is (blessed($obj) , undef, "Not blessed: $description" );
}
