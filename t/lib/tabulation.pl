use strict;
use warnings;
use Test::More;

my $tab_test = [
    [qw/one two three four/],     [qw/five six seven eight/],
    [qw/nine ten eleven twelve/], [qw/thirteen 14 fifteen/],
];

sub test_tabulation {

    my $method = shift;
    my $test_r = shift;

    my $expected    = $test_r->{expected};
    my $description = $test_r->{description};
    my $test_array  = $test_r->{test_array} // $tab_test;
    my @separator;
    my $separator = $test_r->{separator};
    push @separator, $separator if defined $separator;

    my $obj_to_test = Array::2D->clone($test_array);
    my $ref_to_test = Array::2D->clone_unblessed($test_array);

    my $obj_returned = $obj_to_test->$method(@separator);

    is_deeply( $obj_returned, $expected, "$method: $description: object" );

    my $ref_returned = Array::2D->$method( $ref_to_test, @separator );
    is_deeply( $ref_returned, $expected, "$method: $description: ref" );

    return;
} ## tidy end: sub test_tabulation

my %tests = (
    tabulate => [
        {   description => 'an array',
            expected    => [
                'one      two three   four',
                'five     six seven   eight',
                'nine     ten eleven  twelve',
                'thirteen 14  fifteen',
            ],
        },
        {   description => 'an array (with separator)',
            expected    => [
                'one     |two|three  |four',
                'five    |six|seven  |eight',
                'nine    |ten|eleven |twelve',
                'thirteen|14 |fifteen',
            ],
            separator => '|',
        },
        {   description => 'an array with empty strings',
            test_array  => [
                [ qw/one two/, '', 'four' ], [qw/five six seven eight/],
                [ qw/nine ten eleven/, '' ], [qw/thirteen 14 fifteen/],
            ],
            expected => [
                'one      two         four',
                'five     six seven   eight',
                'nine     ten eleven',
                'thirteen 14  fifteen',
            ],
        },
        {   description => 'an array with undefined values',
            test_array  => [
                [ qw/one two/, undef, 'four' ], [qw/five six seven eight/],
                [ qw/nine ten eleven/, undef ], [qw/thirteen 14 fifteen/],
            ],
            expected => [
                'one      two         four',
                'five     six seven   eight',
                'nine     ten eleven',
                'thirteen 14  fifteen',
            ],
        },
        {   description => 'a ragged array',
            test_array  => [
                [ undef, qw/two three four/ ], [qw/five six seven/],
                [ qw/nine ten eleven/, undef ], [qw/thirteen/],
            ],
            expected => [
                '         two three  four',
                'five     six seven',
                'nine     ten eleven',
                'thirteen',
            ],
        },
        {   description => 'a one-column array',
            test_array  => [ ['one'], ['five'], ['nine'], ['thirteen'], ],
            expected => [ 'one', 'five', 'nine', 'thirteen', ],
        },
        {   description => 'a one-row array',
            test_array  => [ [qw/one two three four/] ],
            expected    => ['one two three four'],
        },
        {   description => 'an empty array',
            test_array  => [ [] ],
            expected    => [],
        },

        {   description => 'an array with an empty row',
            test_array  => [
                [qw/one two three/],   [],
                [qw/nine ten eleven/], [qw/thirteen fourteen fifteen/],
            ],
            expected => [
                'one      two      three',
                'nine     ten      eleven',
                'thirteen fourteen fifteen',
            ],
        },
        {   description => 'an array with an empty column',
            test_array  => [
                [ qw/one two/,  '',    'four' ],
                [ qw/five six/, undef, 'eight' ],
                [ qw/nine ten/, '',    'twelve' ],
                [qw/thirteen fourteen/],
            ],
            expected => [
                'one      two      four',
                'five     six      eight',
                'nine     ten      twelve',
                'thirteen fourteen',
            ],
        },
    ],
    tabulate_equal_width => [
        {   description => 'an array',
            expected    => [
                'one      two      three    four',
                'five     six      seven    eight',
                'nine     ten      eleven   twelve',
                'thirteen 14       fifteen',
            ],
        },
        {   description => 'an array (with separator)',
            expected    => [
                'one     |two     |three   |four',
                'five    |six     |seven   |eight',
                'nine    |ten     |eleven  |twelve',
                'thirteen|14      |fifteen',
            ],
            separator => '|',
        },
        {   description => 'an array with empty strings',
            test_array  => [
                [ qw/one two/, '', 'four' ], [qw/five six seven eight/],
                [ qw/nine ten eleven/, '' ], [qw/thirteen 14 fifteen/],
            ],
            expected => [
                'one      two               four',
                'five     six      seven    eight',
                'nine     ten      eleven',
                'thirteen 14       fifteen',
            ],
        },
        {   description => 'an array with undefined values',
            test_array  => [
                [ qw/one two/, undef, 'four' ], [qw/five six seven eight/],
                [ qw/nine ten eleven/, undef ], [qw/thirteen 14 fifteen/],
            ],
            expected => [
                'one      two               four',
                'five     six      seven    eight',
                'nine     ten      eleven',
                'thirteen 14       fifteen',
            ],
        },
        {   description => 'a ragged array',
            test_array  => [
                [ undef, qw/two three four/ ], [qw/five six seven/],
                [ qw/nine ten eleven/, undef ], [qw/thirteen/],
            ],
            expected => [
                '         two      three    four',
                'five     six      seven',
                'nine     ten      eleven',
                'thirteen',
            ],
        },
        {   description => 'a one-column array',
            test_array  => [ ['one'], ['five'], ['nine'], ['thirteen'], ],
            expected => [ 'one', 'five', 'nine', 'thirteen', ],
        },
        {   description => 'a one-row array',
            test_array  => [ [qw/one two three four/] ],
            expected    => ['one   two   three four'],
        },
        {   description => 'an empty array',
            test_array  => [ [] ],
            expected    => [],
        },

        {   description => 'an array with an empty row',
            test_array  => [
                [qw/one two three/],   [],
                [qw/nine ten eleven/], [qw/thirteen 14 fifteen/],
            ],
            expected => [
                'one      two      three',
                'nine     ten      eleven',
                'thirteen 14       fifteen',
            ],
        },
        {   description => 'an array with an empty column',
            test_array  => [
                [ qw/one two/,  '',    'four' ],
                [ qw/five six/, undef, 'eight' ],
                [ qw/nine ten/, '',    'twelve' ],
                [qw/thirteen 14/],
            ],
            expected => [
                'one      two      four',
                'five     six      eight',
                'nine     ten      twelve',
                'thirteen 14',
            ],
        },
    ],
);

#note explain \@tabulated_tests;

my @term_width_list = (
    qw/addfields avl2patdest avl2points avl2stoplines avl2stoplists
      bags2 bartskeds citiesbyline compareskeds comparestops
      dbexport decalcompare decalcount decallabels flagspecs
      htmltables iphoto_stops linedescrip linesbycity
      makepoints matrix mr_copy mr_import newsignup orderbytravel
      prepareflags slists2html ss stops2kml stopsofline storeavl
      tabskeds timetables xhea2skeds zipcodes zipdecals/
);

my $term_width_ref = [
    [qw/addfields     compareskeds  iphoto_stops  orderbytravel timetables/],
    [qw/avl2patdest   comparestops  linedescrip   prepareflags  xhea2skeds/],
    [qw/avl2points    dbexport      linesbycity   slists2html   zipcodes/],
    [qw/avl2stoplines decalcompare  makepoints    ss            zipdecals/],
    [qw/avl2stoplists decalcount    matrix        stops2kml/],
    [qw/bags2         decallabels   mr_copy       stopsofline/],
    [qw/bartskeds     flagspecs     mr_import     storeavl/],
    [qw/citiesbyline  htmltables    newsignup     tabskeds/],
];

my @term_width_tests = (
    {   description => 'made new',
        tabulated   => [
"addfields     compareskeds  iphoto_stops  orderbytravel timetables",
"avl2patdest   comparestops  linedescrip   prepareflags  xhea2skeds",
            "avl2points    dbexport      linesbycity   slists2html   zipcodes",
            "avl2stoplines decalcompare  makepoints    ss            zipdecals",
            "avl2stoplists decalcount    matrix        stops2kml",
            "bags2         decallabels   mr_copy       stopsofline",
            "bartskeds     flagspecs     mr_import     storeavl",
            "citiesbyline  htmltables    newsignup     tabskeds",
        ]
    },
    {   description => 'made new, width 60',
        tabulated   => [
            'addfields     comparestops  linesbycity   ss',
            'avl2patdest   dbexport      makepoints    stops2kml',
            'avl2points    decalcompare  matrix        stopsofline',
            'avl2stoplines decalcount    mr_copy       storeavl',
            'avl2stoplists decallabels   mr_import     tabskeds',
            'bags2         flagspecs     newsignup     timetables',
            'bartskeds     htmltables    orderbytravel xhea2skeds',
            'citiesbyline  iphoto_stops  prepareflags  zipcodes',
            'compareskeds  linedescrip   slists2html   zipdecals'
        ],
        expected => [
            [ 'addfields',     'comparestops', 'linesbycity',   'ss' ],
            [ 'avl2patdest',   'dbexport',     'makepoints',    'stops2kml' ],
            [ 'avl2points',    'decalcompare', 'matrix',        'stopsofline' ],
            [ 'avl2stoplines', 'decalcount',   'mr_copy',       'storeavl' ],
            [ 'avl2stoplists', 'decallabels',  'mr_import',     'tabskeds' ],
            [ 'bags2',         'flagspecs',    'newsignup',     'timetables' ],
            [ 'bartskeds',     'htmltables',   'orderbytravel', 'xhea2skeds' ],
            [ 'citiesbyline',  'iphoto_stops', 'prepareflags',  'zipcodes' ],
            [ 'compareskeds',  'linedescrip',  'slists2html',   'zipdecals' ],
        ],
        width => 60,
    },

    {   description => 'made new with separator',
        separator   => '|',
        tabulated   => [
"addfields    |compareskeds |iphoto_stops |orderbytravel|timetables",
"avl2patdest  |comparestops |linedescrip  |prepareflags |xhea2skeds",
            "avl2points   |dbexport     |linesbycity  |slists2html  |zipcodes",
            "avl2stoplines|decalcompare |makepoints   |ss           |zipdecals",
            "avl2stoplists|decalcount   |matrix       |stops2kml",
            "bags2        |decallabels  |mr_copy      |stopsofline",
            "bartskeds    |flagspecs    |mr_import    |storeavl",
            "citiesbyline |htmltables   |newsignup    |tabskeds",
        ]
    },

);

sub run_tabulation_tests {
    
    if ($_[0] and $_[0] =~ /skip/i) {
        plan skip_all => 'No Unicode::GCString';
        done_testing;
        return;
    }
    
    # So the idea is that when this module is loaded, it will set the
    # %tests and @term_width_tests variables. The loading module
    # can then add whatever tests it feels are appropriate.
    # Finally, the loading module runs run_tabulation_tests to carry 
    # out the tests.

    # generate tests of tabulated() method from tests of tabulate() method

    my @tabulated_tests;
    foreach my $test_r ( @{ $tests{tabulate} } ) {
        my %tabulated_test = %{$test_r};
        $tabulated_test{expected}
          = join( "\n", @{ $tabulated_test{expected} } ) . "\n";
        push @tabulated_tests, \%tabulated_test;
    }
    $tests{tabulated} = \@tabulated_tests;

    # count all the tests and set the Test::More plan to that count

    my $test_count = ( scalar keys %tests ) + 1 + ( 2 * @term_width_tests );
    # methods in keys %tests, plus new_to_term_width,
    # plus 2 tests (obj and tabulation) for everything in @term_width_tests

    foreach my $method ( keys %tests ) {
        $test_count += ( 2 * scalar @{ $tests{$method} } );
        # two tests (obj and ref) per test in %tests
    }

    plan( tests => $test_count );

    # run the main tests (tabulate, tabulated, tabulate_equal_width)

    foreach my $method ( keys %tests ) {
        a2dcan($method);

        for my $test_r ( @{ $tests{$method} } ) {
            test_tabulation( $method, $test_r );
        }
    }

    # run tests for new_to_term_width

    a2dcan('new_to_term_width');

    for my $test_r (@term_width_tests) {

        my $expected       = $test_r->{expected} // $term_width_ref;
        my $tabulated_test = $test_r->{tabulated};
        my $description    = $test_r->{description};
        my %params;
        $params{array} = $test_r->{list} // [@term_width_list];
        $params{width} = $test_r->{width} if defined $test_r->{width};
        $params{separator} = $test_r->{separator}
          if defined $test_r->{separator};

        my ( $array2d_result, $tabulated_result )
          = Array::2D->new_to_term_width(%params);
        is_deeply( $array2d_result, $expected,
            "new from term width: $description: got object" );
        is_deeply( $tabulated_result, $tabulated_test,
            "new_from_term_width: $description: got tabulation" );

    }

    done_testing;

} ## tidy end: sub run_tabulation_tests

