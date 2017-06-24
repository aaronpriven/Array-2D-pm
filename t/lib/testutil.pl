use strict;
use warnings;
use Test::More 0.98;
use Array::2D;

my $builder = Test::More->builder;
binmode $builder->output,         ":encoding(utf8)";
binmode $builder->failure_output, ":encoding(utf8)";
binmode $builder->todo_output,    ":encoding(utf8)";

use Scalar::Util(qw/blessed reftype/);

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

} ## tidy end: sub test_exception (&;@)

# @all_tests is a list rather than a hash (even though it consists of pairs)
# because I want to test the methods in order

sub plan_and_run_generic_tests {
    my @all_tests  = @{ +shift };
    my $defaults_r = shift;

    my $test_count = generic_test_count( \@all_tests, $defaults_r );

    note "result of generic test count: $test_count";

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

    my $test_count = 0;

    while (@all_tests) {
        my $method = shift @all_tests;
        my @tests  = @{ shift @all_tests };
        $test_count += 1;
        # one test per method (a2dcan)

        # two tests (obj and ref) per test in %tests
        # That's why each of the below adds two per test and not just one

        foreach my $test_r (@tests) {
            if ( exists $test_r->{exception} ) {
                $test_count += 4;
                next;
            }
            # if there's an exception, add two, and skip the rest because
            # they're not used if there's an exception test.

            if (   exists $test_r->{expected}
                or exists $defaults_r->{$method}{expected} )
            {
                $test_count += 2;
            }

            if (   exists $test_r->{warning}
                or exists $defaults_r->{$method}{warning} )
            {
                $test_count += 2;
            }
            if ( exists $defaults_r->{$method}{check_blessing} ) {
                $test_count += 2;
            }
            if (   exists $test_r->{altered}
                or exists( $defaults_r->{$method}{altered} ) )
            {
                $test_count += 2;
            }

            # two more tests (for the warning or exception text)
            # for each of obj and ref) per test with a warning

        } ## tidy end: foreach my $test_r (@tests)

    } ## tidy end: while (@all_tests)

    return $test_count;

} ## tidy end: sub generic_test_count

my $has_test_warn;

sub generic_test {

    my $method = shift;
    my %t = _get_test_factors( $method, @_ );
    
    
    # o) test results, ensure array doesn't change
    # o) test results, also test array change
    # o) test array change, ignore results
    # o) in non-void context, array doesn't change, test results.
    #    in void context, array changes to what results would have been
    #       in non-void context.
    
    my $has_expected = exists $t{expected};
    my $description  = $t{description};       # easier to interpolate

    my @arguments = _get_arguments( \%t );

    my %to_test = (
        object => Array::2D->clone( $t{test_array} ),
        ref    => Array::2D->clone_unblessed( $t{test_array} )
    );

    my %process = (
        object => sub { $to_test{object}->$method(@arguments) },
        ref    => sub { Array::2D->$method( $to_test{ref}, @arguments ) }
    );

    if ( $t{exception} ) {
        test_exception { $process{object}->() } $t{description}, $t{exception};
        test_exception { $process{ref}->() } $t{description},    $t{exception};
        return;
    }

    foreach my $type (qw/object ref/) {

        my $returned;

        if ( $t{warning} ) {
            _check_for_test_warn() unless defined $has_test_warn;

          SKIP: {
                skip( 'Test::Warn not available', 1 ) unless $has_test_warn;
                warning_like {
                    $returned
                      = $t{returns_a_list}
                      ? [ $process{$type}->() ]
                      : $process{$type}->();
                }
                { carped => $t{warning} },
                  "$method: $description: object: gave correct warning";
            }
        }
        else {
            $returned
              = $t{returns_a_list}
              ? [ $process{$type}->() ]
              : $process{$type}->();
        }

        is_deeply( $returned, $t{expected},
            "$method: $description: $type: correct result" )
          if $has_expected;

        if ( $t{check_blessing} ) {
            if ( $t{check_blessing} eq 'always'
                or
                ( $t{check_blessing} eq 'as_oriignal' and $type eq 'object' ) )
            {
                is_blessed($returned);
            }
            elsif ( $t{check_blessing} eq 'as_original' ) {
                isnt_blessed($returned);
            }
            else {

                fail 'Unknown blessing check type: ' . $t{check_blessing};
            }
        }
        if ( exists $t{altered} ) {
            if ( reftype $t{altered} eq 'ARRAY' ) {
                is_deeply( $to_test{$type}, $t{altered},
                    "$method: $description: $type: altered $type correctly" );
            }
            elsif ( $t{altered} == 0 ) {
                is_deeply( $to_test{$type}, $t{test_array},
                    "... and it did not alter the $type" );
            }
            else {
                fail 'Unknown alteration: ' . explain $t{altered};
            }
        }

    } ## tidy end: foreach my $type (qw/object ref/)

    if ( exists $t{in_place} ) {

        my %to_test_ip = (
            object => Array::2D->clone( $t{test_array} ),
            ref    => Array::2D->clone_unblessed( $t{test_array} )
        );

        my %process_ip = (
            object => sub { $to_test_ip{object}->$method(@arguments) },
            ref    => sub { Array::2D->$method( $to_test_ip{ref}, @arguments ) }
        );

        foreach my $type (qw/object ref/) {

            $process_ip{$type}->();
            is_deeply(
                $to_test{$type}, $t{expected},
                "$method in place: $description: $type: altered correctly"
            );

        }

    } ## tidy end: if ( exists $t{in_place...})

    return;

} ## tidy end: sub generic_test

sub _get_test_factors {

    my $method = shift;
    my %t;
    my $test_r = shift;
    my $defaults_r = shift // {};

    foreach my $test_factor (
        qw[
        altered
        arguments
        check_blessing
        description
        exception
        expected
        in_place
        returns_a_list
        test_array
        warning
        ]
      )
    {

        if ( exists $test_r->{$test_factor} ) {
            $t{$test_factor} = $test_r->{$test_factor};
        }
        elsif ( exists $defaults_r->{$method}{$test_factor} ) {
            $t{$test_factor} = $test_r->{$test_factor};
        }
    } ## tidy end: foreach my $test_factor ( qw[...])

    return %t;

} ## tidy end: sub _get_test_factors

sub _get_arguments {
    my $t_r = shift;

    my @arguments;

    if ( defined $t_r->{arguments} ) {
        if ( ref $t_r->{arguments} eq 'ARRAY' ) {
            @arguments = @{ $t_r->{arguments} };
        }
        else {
            @arguments = $t_r->{arguments};
        }
    }

}

sub _check_for_test_warn {
    if ( eval { require Test::Warn; 1 } ) {
        $has_test_warn = 1;
    }
    else {
        $has_test_warn = 0;
    }
}

1;
