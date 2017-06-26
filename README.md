# NAME

Array::2D - Methods for simple array-of-arrays data structures

# VERSION

This documentation refers to version 0.001\_001

# NOTICE

This is alpha software.  Method names and behaviors are subject to change.
The test suite has significant omissions.

# SYNOPSIS

    use Array::2D;
    my $array2d = Array::2D->new( [ qw/a b c/ ] , [ qw/w x y/ ] );

    # $array2d contains

    #     a  b  c
    #     w  x  y

    $array2d->push_col (qw/d z/);

    #     a  b  c  d
    #     w  x  y  z

    say $array2d->[0][1];
    # prints "b"

# DESCRIPTION

Array::2D is a module that adds useful methods to Perl's
standard array of arrays ("AoA") data structure, as described in 
[Perl's perldsc documentation](https://metacpan.org/pod/perldsc) and 
[Perl's perllol documentation](https://metacpan.org/pod/perllol).  That is, an array that
contains other arrays:

    [ 
      [ 1, 2, 3 ] , 
      [ 4, 5, 6 ] ,
    ]

This module provides methods for using that standard construction.

# DOCUMENTATION

Full documentation is located in "plain old documentation" within
the 2D.pm module.

# AUTHOR

Aaron Priven <apriven@actransit.org>

# COPYRIGHT & LICENSE

Copyright 2015, 2017

This program is free software; you can redistribute it and/or modify it
under the terms of either:

- the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
- the Artistic License version 2.0.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
