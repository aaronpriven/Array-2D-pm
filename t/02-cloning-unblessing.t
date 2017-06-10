use strict;
use Test::More 0.98;
use Test::Fatal;

use Array::2D;
use Scalar::Util(qw/blessed refaddr/);

note "Testing clone, unbless, clone_unblessed";

use Cwd;

do './t/lib/array-2d.pl' // do './lib/array-2d.pl'
  // die "Can't load array-2d.pl";

our ( $sample_ref, $sample_test, $sample_obj );

##########
# ->clone

my $clone_from_ref = Array::2D->clone($sample_ref);

is_deeply( $clone_from_ref, $sample_test,
    "Array::2D->clone clones from a reference AoA" );
is_blessed( $clone_from_ref, "Clone from reference AoA" );
isnt( refaddr($clone_from_ref),
    refaddr($sample_ref), 'Clone is not the same reference as reference AoA' );
ok( all_row_refs_are_different( $clone_from_ref, $sample_ref ),
    'No reference in clone is the same as the reference AoA'
);

my $clone_from_obj = $sample_obj->clone();

is_deeply( $clone_from_obj, $sample_test, '$obj->clone clones from an object' );
is_blessed( $clone_from_obj, "Clone from object" );
isnt( refaddr($clone_from_obj),
    refaddr($sample_ref), 'Clone is not the same reference as object' );
ok( all_row_refs_are_different( $clone_from_obj, $sample_ref ),
    'No reference in clone is the same as in the object'
);

##############
# ->unblessed

my $unblessed_from_ref = Array::2D->unblessed($sample_ref);
is_deeply( $unblessed_from_ref, $sample_test, 'unblessed() from ref returns AoA' );
isnt_blessed($unblessed_from_ref, "unblessed from reference");
note 'References are '
  . ( $unblessed_from_ref == $sample_ref ? 'equal' : 'not equal' );
  
my $unblessed_from_obj = $sample_obj->unblessed();  
is_deeply( $unblessed_from_obj, $sample_test, '$obj->unblessed returns AoA' );
isnt_blessed($unblessed_from_obj, "unblessed from object");
note 'References are '
  . ( $unblessed_from_obj == $sample_ref ? 'equal' : 'not equal' );
  

####################
# ->clone_unblessed

my $unblessedclone_from_ref = Array::2D->clone_unblessed($sample_ref);

is_deeply( $unblessedclone_from_ref, $sample_test,
    "Array::2D->clone clones from a reference AoA" );
isnt_blessed( $unblessedclone_from_ref, "Clone from reference AoA" );
isnt( refaddr($unblessedclone_from_ref),
    refaddr($sample_ref), 'Clone is not the same reference as reference AoA' );
ok( all_row_refs_are_different( $unblessedclone_from_ref, $sample_ref ),
    'No reference in clone is the same as the reference AoA'
);

my $unblessedclone_from_obj = $sample_obj->clone_unblessed();

is_deeply( $unblessedclone_from_obj, $sample_test,
    '$obj->clone_unblessed clones from an object' );
isnt_blessed( $unblessedclone_from_obj, "Unblessed clone from object" );
isnt( refaddr($unblessedclone_from_obj),
    refaddr($sample_ref), 'Clone is not the same reference as object' );
ok( all_row_refs_are_different( $unblessedclone_from_obj, $sample_ref ),
    'No reference in clone is the same as in the object' );

sub all_row_refs_are_different {
    my $aoa  = shift;
    my $aoa2 = shift;
    for my $row_idx ( 0 .. $#{$aoa} ) {
        return 0
          if refaddr( $aoa->[$row_idx] ) == refaddr( $aoa2->[$row_idx] );
    }
    return 1;
}

done_testing;
