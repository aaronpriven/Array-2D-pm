use strict;
use warnings;
use Test::More 0.98;

my $builder = Test::More->builder;
binmode $builder->output,         ":encoding(utf8)";
binmode $builder->failure_output, ":encoding(utf8)";
binmode $builder->todo_output,    ":encoding(utf8)";

use Scalar::Util(qw/blessed/);

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
    my @methods = @_;

    if ( @_ == 1 ) {
        note "Testing $_[0]()";
    }
    else {
        note "Testing methods: @_";
    }

    can_ok( 'Array::2D', @_ );
}

my $has_test_fatal;

sub test_exception (&;@) {
    my $code        = shift;
    my $description = shift;
    my $regex       = shift;

    if ( not defined $has_test_fatal ) {
        if ( eval { require Test::Fatal; 1 } ) {
            $has_test_fatal = 1;
            Test::Fatal->import();
        }
        else {
            $has_test_fatal = 0;
        }
    }

  SKIP: {
        skip( 'Test::Fatal not available', 2 ) unless $has_test_fatal;

        my $exception_obj = &exception($code);
        #  bypass prototype
        isnt( $exception_obj, undef, $description );
        like( $exception_obj, $regex, "... and it's the expected exception" );

    }

} 

1;
