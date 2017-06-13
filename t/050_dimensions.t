use strict;
use warnings;

BEGIN {
    do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
      // die "Can't load array-2d.pl";
}

our ( $sample_obj,  $sample_ref,  $empty_obj,   $empty_ref );
our ( $one_row_obj, $one_row_ref, $one_col_obj, $one_col_ref );

# you know my @methods, Watson
my @methods = (qw/height width last_row last_col/);

my @subjects = (
    [ 'sample',     $sample_obj,  $sample_ref,  10, 5 ],
    [ 'one-row',    $one_row_obj, $one_row_ref, 1,  5 ],
    [ 'one-column', $one_col_obj, $one_col_ref, 10, 1 ],
    [ 'empty',      $empty_obj,   $empty_ref,   0,  0 ],
);

plan tests => ( @methods + 1 ) * ( @subjects * 2 + 1 );
# add one method for is_empty and one subject for test_can

note "Testing is_empty()";

a2dcan('is_empty');

foreach my $subject_r (@subjects) {
    my ( $name, $obj, $ref, $height, $width ) = @$subject_r;
    push @{$subject_r}, $height - 1, $width - 1;
    # add last_row and last_column for later
    if ( $name eq 'empty' ) {
        ok( $obj->is_empty(),          "is_empty true: empty object" );
        ok( Array::2D->is_empty($ref), "is_empty true: empty reference" );
    }
    else {
        ok( not( $obj->is_empty() ), "is_empty false: $name object" );
        ok( not( Array::2D->is_empty($ref) ),
            "is_empty false: $name reference"
        );
    }
}

foreach my $method_idx ( 0 .. $#methods ) {
    my $method = $methods[$method_idx];

    note "Testing $method()";
    a2dcan($method);

    foreach my $subject_r (@subjects) {
        my ( $name, $obj, $ref, @values ) = @{$subject_r};
        my $value = $values[$method_idx];

        cmp_ok( $obj->$method, '==', $value, "$method() on $name object" )
          ;
        cmp_ok( Array::2D->$method($ref),
            '==', $value, "$method() on $name reference" );
    }

}

