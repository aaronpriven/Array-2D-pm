use strict;
use Test::More 0.98;
use Test::Fatal;

plan(tests => 20);
# yes, I have a plan(), but do I have an environmental_impact_report() and
# an alternatives_analysis() ?

use Array::2D;
use Scalar::Util(qw/blessed refaddr/);

note ("Testing new, new_across, new_down, bless");

##########
# ->new()

# EMPTY

my $empty_obj = Array::2D->new();
is_deeply( $empty_obj, [ [] ], "New empty object created" );
is_blessed_correctly( $empty_obj, "new empty object" );

# FROM A REF

my $from_ref
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];
my $from_ref_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $new_from_ref = Array::2D->new($from_ref);
is_deeply( $new_from_ref, $from_ref_test,
    "new(): Object created from reference" );
is_blessed_correctly( $new_from_ref, "new(): Object created from reference" );

# FROM BROKEN ARRAY WITH A NON-REF MEMBER

my @broken = ( [qw/a b/], 'not_a_ref', [qw/c d/] );

my $exception = exception( sub { Array::2D->new(@broken); } );
isnt( $exception, undef,
    "new() throws exception with a row that's a non-reference" );
like(
    $exception,
    qr/Arguments to.*must be arrayrefs/i,
    "new() dies with correct message with non-reference row"
);

# FROM A SINGLE REF (a row)

my $one_row_ref = [qw/a b c/];
my $one_row_test = [ [qw/a b c/] ];

my $one_row_obj = Array::2D->new($one_row_ref);

is_deeply( $new_from_ref, $from_ref,
    "new(): Object created from reference with one row" );
is_blessed_correctly( $new_from_ref,
    "new(): Object created from reference with one row" );

# FROM ARRAY

my @array
  = ( [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], );

my $from_array_test
  = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ], ];

my $from_array = Array::2D->new(@array);
is_deeply( $from_array, $from_array_test, 'new(): Object created from array' );
is_blessed_correctly( $new_from_ref, "new(): Object created from array" );

#################
# ->new_across()

my @across_flat = ( 'a', '1', 'X', -1, 'b', '2', 'Y', -2, 'c', '3', 'Z', -3 );
my $across_2d = Array::2D->new_across( 4, @across_flat );

is_deeply( $across_2d, $from_array_test, 'new_across() creates object' );
is_blessed_correctly( $new_from_ref, "Object created via new_across()" );

###############
# ->new_down()

my @down_flat = ( 'a', 'b', 'c', '1', '2', '3', 'X', 'Y', 'Z', -1, -2, -3 );
my $down_2d = Array::2D->new_across( 4, @across_flat );

is_deeply( $down_2d, $from_array_test, 'new_down() creates object' );
is_blessed_correctly( $new_from_ref, "Object created via new_down()" );

##############
# ->bless()

my $unblessed_sample = [ [qw/i j/], [qw/k l/] ];
my $from_unblessed_sample = Array::2D->bless($unblessed_sample);

ok( $unblessed_sample == $from_unblessed_sample,
    "bless() returns same ref when that ref is unblessed" );
is_blessed_correctly( $from_unblessed_sample, "Result of bless() on unblessed ref" );


my $blessed_sample = bless [ [] ], 'Array::2D';
my $reblessed_sample = Array::2D->bless($blessed_sample);

ok( $reblessed_sample == $blessed_sample,
    "Bless returns same ref when that ref is blessed into Array::2D" );
is_blessed_correctly( $reblessed_sample,
    "Result of bless() when ref is blessed into Array::2D" );

my $other_object = bless [ [] ], 'Dummyclass';

my $blessing_exception = exception( sub { Array::2D->bless($other_object); } );
isnt( $blessing_exception, undef,
    "bless() throws exception with object blessed in other class" );
like(
    $blessing_exception,
    qr/Cannot re-bless existing object/i,
    "bless() dies with correct message with object blessed in other class"
);

sub is_blessed_correctly {
    my $obj         = shift;
    my $description = shift;
    my $class       = blessed $obj;
    ok( blessed($obj) eq 'Array::2D', "blessed correctly: $description" );
}
1;
