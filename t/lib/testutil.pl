use strict;
use warnings;
use Test::More 0.98;
use Array::2D;

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
        }
        else {
            $has_test_fatal = 0;
        }
    }

  SKIP: {
        skip( 'Test::Fatal not available', 2 ) unless $has_test_fatal;

        my $exception_obj = &Test::Fatal::exception($code);
        #  bypass prototype
        isnt( $exception_obj, undef, $description );
        like( $exception_obj, $regex, "... and it's the expected exception" );

    }

} ## tidy end: sub SUB0

sub plan_and_run_generic_tests {

    my @all_tests  = @{ +shift };
    my $defaults_r = shift;

    my $test_count = generic_test_count( \@all_tests, $defaults_r );

    plan( tests => $test_count );

    run_generic_tests( \@all_tests, $defaults_r );

    done_testing;

}

sub run_generic_tests {

    my @all_tests  = @{ +shift };
    my $defaults_r = shift;

    while (@all_tests) {
        my $method  = shift @all_tests;
        my $tests_r = shift @all_tests;

        a2dcan($method);

        foreach my $test_r ( @{$tests_r} ) {
            generic_test( $method, $test_r, $defaults_r, );
        }

    }

}

sub generic_test_count {
    my @all_tests  = @{ +shift };
    my $defaults_r = shift;

    my $test_count;

    while (@all_tests) {
        my $method = shift @all_tests;
        my @tests  = @{ shift @all_tests };
        $test_count += 1;
        # one test per method (a2dcan)

        $test_count += ( 2 * scalar @tests );
        # two tests (obj and ref) per test in %tests

        $test_count += ( 2 * scalar @tests )
          if $defaults_r->{$method}{check_blessing};
        # two tests (obj and ref) if blessing is checked

        $test_count += ( 2 * scalar @tests )
          if $defaults_r->{$method}{check_alteration};
        # two tests (obj and ref) if alteration is checked

        foreach my $test_r (@tests) {
            $test_count += 2 if exists $test_r->{warning};
        }
        # two more tests (for the warning texti for each of obj and ref)
        # per test with a warning

    } ## tidy end: while (@all_tests)

    return $test_count;

} ## tidy end: sub generic_test_count

my $has_test_warn;

sub generic_test {

    my $method = shift;

    my $test_r           = shift;
    my $defaults_r       = shift // {};
    my $returns_a_list   = $defaults_r->{$method}{returns_a_list};
    my $check_blessing   = $defaults_r->{$method}{check_blessing};
    my $check_alteration = $defaults_r->{$method}{check_alteration};

    my $expected = $test_r->{expected} // $defaults_r->{$method}{expected};
    my $description = $test_r->{description}
      // $defaults_r->{$method}{description};
    my $test_array = $test_r->{test_array}
      // $defaults_r->{$method}{test_array};
    my $warning     = $test_r->{warning}   // $defaults_r->{$method}{warning};
    my $arguments_r = $test_r->{arguments} // $defaults_r->{$method}{arguments};
    my @arguments;

    if ( defined $arguments_r ) {
        if ( ref $arguments_r eq 'ARRAY' ) {
            @arguments = @$arguments_r;
        }
        else {
            @arguments = ($arguments_r);
        }
    }

    my $obj_to_test = Array::2D->clone($test_array);
    my $ref_to_test = Array::2D->clone_unblessed($test_array);

    my ( $obj_returned, $ref_returned );

    if ($warning) {
        if ( not defined $has_test_warn ) {
            if ( eval { require Test::Warn; 1 } ) {
                $has_test_warn = 1;
            }
            else {
                $has_test_warn = 0;
            }
        }

      SKIP: {
            skip( 'Test::Warn not available', 1 ) unless $has_test_warn;
            warning_like {
                $obj_returned
                  = $returns_a_list
                  ? [ $obj_to_test->$method(@arguments) ]
                  : $obj_to_test->$method(@arguments);
            }
            { carped => $warning },
              "$method: $description: object: gave warning";

        }
    } ## tidy end: if ($warning)
    else {
        $obj_returned
          = $returns_a_list
          ? [ $obj_to_test->$method(@arguments) ]
          : $obj_to_test->$method(@arguments);
    }

    is_deeply( $obj_returned, $expected,
        "$method: $description: object: correct" );
    is_blessed($obj_returned) if ($check_blessing);

    is_deeply( $obj_to_test, $test_array,
        '... and it did not alter the object' )
      if $check_alteration;

    if ($warning) {
      SKIP: {
            skip( 'Test::Warn not available', 1 ) unless $has_test_warn;
            warning_like {
                $ref_returned
                  = $returns_a_list
                  ? [ Array::2D->$method( $ref_to_test, @arguments ) ]
                  : Array::2D->$method( $ref_to_test, @arguments );
            }
            { carped => $warning }, "$method: $description: ref: gave warning";
        }
    }
    else {
        $ref_returned
          = $returns_a_list
          ? [ Array::2D->$method( $ref_to_test, @arguments ) ]
          : Array::2D->$method( $ref_to_test, @arguments );
    }
    # there's an arrayref constructor around each of the
    # $ref_returned assignments

    is_deeply( $ref_returned, $expected,
        "$method: $description: ref: correct" );

    is_deeply( $ref_to_test, $test_array,
        '... and it did not alter the reference' )
      if $check_alteration;

    if ($check_blessing) {
        is_blessed($obj_returned)   if ( $check_blessing eq 'always' );
        isnt_blessed($obj_returned) if ( $check_blessing eq 'as_original' );
    }

    return;

} ## tidy end: sub generic_test

1;
