use strict;
use warnings;

BEGIN {
    do './t/lib/tabulation.pl' // do './lib/tabulation.pl'
      // die "Can't load tabulation.pl";
}

note('Use Unicode::GCString for determining column widths');

if ( eval { require Unicode::GCString; 1 } ) {

    our %tests;

    push @{ $tests{tabulate} },
      ( {   description => 'an array with Unicode decomposed characters',
            test_array  => [
                [ '_11_chars__',      'q' ],
                [ 'solo',             'alone' ],
                [ "so\x{301}lo",      'only' ],
                [ "dieciseis",        'sixteen' ],
                [ "diecise\x{301}is", 'sixteen' ],
            ],
            expected => [
                '_11_chars__ q',
                'solo        alone',
                "so\x{301}lo        only",
                "dieciseis   sixteen",
                "diecise\x{301}is   sixteen",
            ],
        },
        {   description => 'an array with double-wide characters',
            test_array  => [
                [ "\x{4300}", "Chinese character for one", ],
                [ '1',        'Arabic numeral one', ],
                [ 'uno',      'Spanish word for one' ],
            ],
            expected => [
                "\x{4300}  Chinese character for one",
                '1   Arabic numeral one',
                'uno Spanish word for one',
            ],
        },
      );

    push @{ $tests{tabulate_equal_width} },
      ( {   description => 'an array with Unicode decomposed characters',
            test_array  => [
                [ "so\x{301}lo", 'only', 'a' ],
                [qw/solo alone b/],
                [ "diecise\x{301}is", 'sixteen', 'c' ],
            ],
            expected => [
                "so\x{0301}lo      only      a",
                'solo      alone     b',
                "diecise\x{301}is sixteen   c",
            ],
        },
        {   description => 'an array with double-wide characters',
            test_array  => [
                [ "\x{4300}", 'Chinese', 'a' ],
                [ '1',        'Arabic',  'b' ],
                [ 'uno',      'Spanish', 'c' ],
            ],
            expected => [
                "\x{4300}      Chinese a",
                , '1       Arabic  b',
                , 'uno     Spanish c',
            ],
        },
      );

    run_tabulation_tests();

} ## tidy end: if ( eval { require Unicode::GCString...})
else {
    plan skip_all => 'Unicode::GCString not available';
    done_testing;
}
