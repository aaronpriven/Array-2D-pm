use strict;
use warnings;
use Test::More 0.98;
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

1;
