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
    is( blessed($obj), undef, "Not blessed: $description" );
}

# cannot use the array-2d.pl library for is_blessed and isnt_blessed
# because array-2d.pl uses new() in it and we haven't tested that yet

sub test_simple_construction {
    
     if ($_[0] and $_[0] =~ /skip/i) {
        plan skip_all => 'No Ref::Util';
        done_testing;
        return;
    } 

    plan( tests => 34 );
    # yes, I have a plan(), but do I have an environmental_impact_report() and
    # an alternatives_analysis() ?

############
    # ->empty

    note 'Testing ->empty()';

    can_ok( 'Array::2D', 'empty' );

    my $empty_obj_from_empty = Array::2D->empty();
    is_deeply( $empty_obj_from_empty, [], "empty(): New empty object created" );
    is_blessed( $empty_obj_from_empty, "empty(): new empty object" );

########################
    # ->new() and ->bless()

    for my $method (qw/new bless/) {

        note "Testing ->$method()";

        can_ok( 'Array::2D', $method );

        # EMPTY

        my $empty_obj = Array::2D->$method();
        is_deeply( $empty_obj, [], "$method(): New empty object created" );
        is_blessed( $empty_obj, "$method(): new empty object" );

        # FROM ARRAY

        my @array = (
            [ 'a', '1', 'X', -1 ],
            [ 'b', '2', 'Y', -2 ],
            [ 'c', '3', 'Z', -3 ],
        );

        my $from_array_test = [
            [ 'a', '1', 'X', -1 ],
            [ 'b', '2', 'Y', -2 ],
            [ 'c', '3', 'Z', -3 ],
        ];

        my $from_array = Array::2D->$method(@array);
        is_deeply( $from_array, $from_array_test,
            "$method(): Object created from array" );
        is_blessed( $from_array, "$method(): Object created from array" );

        # FROM EXISTING OBJECT

        my $existing_obj = bless [ [] ], 'Array::2D';
        my $new_from_existing_obj = Array::2D->$method($existing_obj);
        cmp_ok( $new_from_existing_obj, '==', $existing_obj,
            "$method(): already-blessed object is returned as is'" );

        # FROM BROKEN ARRAY WITH A NON-REF MEMBER

        my @broken = ( [qw/a b/], 'not_a_ref', [qw/c d/] );

        my $exception = exception( sub { Array::2D->$method(@broken); } );
        isnt( $exception, undef,
            "$method() throws exception with a row that's a non-reference" );
        like(
            $exception,
            qr/must be unblessed arrayrefs/i,
            "$method() dies with correct message with non-reference row"
        );

        # FROM A SINGLE REF (a row)

        my $one_row_ref = [qw/a b c/];
        my $one_row_test = [ [qw/a b c/] ];

        my $one_row_obj = Array::2D->$method($one_row_ref);

        is_deeply( $one_row_obj, $one_row_test,
            "$method(): Object created from reference with one row" );
        is_blessed( $one_row_obj,
            "$method(): Object created from reference with one row" );

        # this is done in the loop only to get the "note" text
        # in the right place
        if ( $method eq 'new' ) {

            # ->new() FROM A REF

            my $from_ref = [
                [ 'a', '1', 'X', -1 ],
                [ 'b', '2', 'Y', -2 ],
                [ 'c', '3', 'Z', -3 ],
            ];
            my $from_ref_test = [
                [ 'a', '1', 'X', -1 ],
                [ 'b', '2', 'Y', -2 ],
                [ 'c', '3', 'Z', -3 ],
            ];

            my $new_from_ref = Array::2D->new($from_ref);
            is_deeply( $new_from_ref, $from_ref_test,
                "new(): Object created from reference" );
            is_blessed( $new_from_ref, "new(): Object created from reference" );
            isnt_blessed( $from_ref,
                'new(): passed reference itself is not blessed' );

        } ## tidy end: if ( $method eq 'new' )
        else {

            # ->bless() FROM A REF

            my $from_ref_bless = [
                [ 'a', '1', 'X', -1 ],
                [ 'b', '2', 'Y', -2 ],
                [ 'c', '3', 'Z', -3 ],
            ];
            my $from_ref__bless_test = [
                [ 'a', '1', 'X', -1 ],
                [ 'b', '2', 'Y', -2 ],
                [ 'c', '3', 'Z', -3 ],
            ];
            my $new_from_ref_bless = Array::2D->bless($from_ref_bless);
            cmp_ok( $new_from_ref_bless, '==', $from_ref_bless,
                'bless(): arrayref of arrayrefs is itself returned' );
            is_blessed( $new_from_ref_bless, "bless(): arrayref of arrayrefs" );

        } ## tidy end: else [ if ( $method eq 'new' )]

    } ## tidy end: for my $method (qw/new bless/)

#################
    # ->new_across()

    my $across_and_down_test
      = [ [ 'a', '1', 'X', -1 ], [ 'b', '2', 'Y', -2 ], [ 'c', '3', 'Z', -3 ],
      ];

    note 'Testing new_across()';

    can_ok( 'Array::2D', 'new_across' );

    my @across_flat
      = ( 'a', '1', 'X', -1, 'b', '2', 'Y', -2, 'c', '3', 'Z', -3 );
    my $across_2d = Array::2D->new_across( 4, @across_flat );

    is_deeply( $across_2d, $across_and_down_test,
        'new_across() creates object' );
    is_blessed( $across_2d, "Object created via new_across()" );

###############
    # ->new_down()

    can_ok( 'Array::2D', 'new_down' );

    my @down_flat = ( 'a', 'b', 'c', '1', '2', '3', 'X', 'Y', 'Z', -1, -2, -3 );
    my $down_2d = Array::2D->new_down( 3, @down_flat );

    is_deeply( $down_2d, $across_and_down_test, 'new_down() creates object' );
    is_blessed( $down_2d, "Object created via new_down()" );

    return;

} ## tidy end: sub test_simple_construction

1;
