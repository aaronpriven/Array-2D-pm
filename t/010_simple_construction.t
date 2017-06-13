use strict;
use warnings;
use Test::More 0.98;
use lib './lib';
use Array::2D;
use Scalar::Util(qw/blessed refaddr/);

use Test::Fatal;

sub is_blessed {
    my $obj = shift;
    my $description = shift // q[];
    is( blessed($obj), 'Array::2D', "blessed correctly: $description" );
}

sub isnt_blessed {
   my $obj = shift;
   my $description = shift // q[];
   is (blessed($obj) , undef, "Not blessed: $description" );
}

# cannot use the array-2d.pl library for is_blessed and isnt_blessed
# because array-2d.pl uses new() in it and we haven't tested that yet

plan( tests => 31 );
# yes, I have a plan(), but do I have an environmental_impact_report() and
# an alternatives_analysis() ?

note 'Testing ->new()';

ok(Array::2D->can('new'), 'Can new()');

{ 
    # scoping so all the lexical variables 
    # go out of scope before we get to testing bless()

# EMPTY

my $empty_obj = Array::2D->new();
is_deeply( $empty_obj, [ [] ], "new(): New empty object created" );
is_blessed( $empty_obj, "new(): new empty object" );

# FROM A REF

my $from_ref
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];
my $from_ref_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $new_from_ref = Array::2D->new($from_ref);
is_deeply( $new_from_ref, $from_ref_test,
    "new(): Object created from reference" );
is_blessed( $new_from_ref, "new(): Object created from reference" );
isnt_blessed( $from_ref, 'new(): passed reference itself is not blessed' );

# FROM EXISTING OBJECT

my $existing_obj = bless [ [] ], 'Array::2D';
my $new_from_existing_obj = Array::2D->new($existing_obj);
cmp_ok( $new_from_existing_obj, '==', $existing_obj,
    'new(): already-blessed object is returned as is' );

# FROM BROKEN ARRAY WITH A NON-REF MEMBER

my @broken = ( [qw/a b/], 'not_a_ref', [qw/c d/] );

my $exception = exception( sub { Array::2D->new(@broken); } );
isnt( $exception, undef,
    "new() throws exception with a row that's a non-reference" );
like(
    $exception,
    qr/must be unblessed arrayrefs/i,
    "new() dies with correct message with non-reference row"
);

# FROM A SINGLE REF (a row)

my $one_row_ref = [qw/a b c/];
my $one_row_test = [ [qw/a b c/] ];

my $one_row_obj = Array::2D->new($one_row_ref);

is_deeply( $new_from_ref, $from_ref,
    "new(): Object created from reference with one row" );
is_blessed( $new_from_ref,
    "new(): Object created from reference with one row" );

# FROM ARRAY

my @array
  = ( [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], );

my $from_array_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $from_array = Array::2D->new(@array);
is_deeply( $from_array, $from_array_test, 'new(): Object created from array' );
is_blessed( $new_from_ref, "new(): Object created from array" );

}

############
# ->bless()

note 'Testing ->bless()';

ok(Array::2D->can('new'), 'Can bless()');

# EMPTY

my $empty_obj = Array::2D->bless();
is_deeply( $empty_obj, [ [] ], "bless(): New empty object created" );
is_blessed( $empty_obj, "bless(): new empty object" );

# FROM A REF

my $from_ref
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];
my $from_ref_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $new_from_ref = Array::2D->bless($from_ref);
cmp_ok( $new_from_ref, '==', $from_ref,
    'bless(): arrayref of arrayrefs is itself returned' );
is_blessed( $new_from_ref, "bless(): arrayref of arrayrefs" );

# FROM EXISTING OBJECT

my $existing_obj = bless [ [] ], 'Array::2D';
my $new_from_existing_obj = Array::2D->bless($existing_obj);
cmp_ok( $new_from_existing_obj, '==', $existing_obj,
    'bless(): already-blessed object is returned as is' );

# FROM BROKEN ARRAY WITH A NON-REF MEMBER

my @broken = ( [qw/a b/], 'not_a_ref', [qw/c d/] );

my $exception = exception( sub { Array::2D->bless(@broken); } );
isnt( $exception, undef,
    "bless() throws exception with a row that's a non-reference" );
like(
    $exception,
    qr/must be unblessed arrayrefs/i,
    "bless() dies with correct message with non-reference row"
);

# FROM A SINGLE REF (a row)

my $one_row_ref = [qw/a b c/];
my $one_row_test = [ [qw/a b c/] ];

my $one_row_obj = Array::2D->bless($one_row_ref);

is_deeply( $new_from_ref, $from_ref,
    "bless(): Object created from reference with one row" );
is_blessed( $new_from_ref,
    "bless(): Object created from reference with one row" );

# FROM ARRAY

my @array
  = ( [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], );

my $from_array_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $from_array = Array::2D->bless(@array);
is_deeply( $from_array, $from_array_test, 'bless(): Object created from array' );
is_blessed( $new_from_ref, "bless(): Object created from array" );

#################
# ->new_across()

note 'Testing new_across()';

ok(Array::2D->can('new_across'), 'Can new_across()');
my @across_flat = ( 'a', '1', 'X', -1, 'b', '2', 'Y', -2, 'c', '3', 'Z', -3 );
my $across_2d = Array::2D->new_across( 4, @across_flat );

is_deeply( $across_2d, $from_array_test, 'new_across() creates object' );
is_blessed( $new_from_ref, "Object created via new_across()" );

###############
# ->new_down()

note 'Testing new_down()';

ok(Array::2D->can('new_down'), 'Can new_down()');

my @down_flat = ( 'a', 'b', 'c', '1', '2', '3', 'X', 'Y', 'Z', -1, -2, -3 );
my $down_2d = Array::2D->new_down( 3, @down_flat );

is_deeply( $down_2d, $from_array_test, 'new_down() creates object' );
is_blessed( $down_2d, "Object created via new_down()" );

1;
