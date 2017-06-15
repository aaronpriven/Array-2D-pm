# NAME

Array:2D - Methods for simple array-of-arrays data structures

# VERSION

This documentation refers to version 0.001\_001

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

Most of the time, it's good practice to avoid having programs that use
a module know about the internal construction of an object. However,
this module is not like that. It exists purely to give methods to a
standard construction in Perl, and will never change the data structure
to include anything else. Therefore, it is perfectly reasonable to use
the normal reference syntax to access items inside the array. A
construction like `$array2d->[0][1]`  for accessing a single
element, or `@{$array2d}` to get the list of rows, is perfectly
acceptable. This module exists because the reference-based 
implementation of multidimensional arrays in Perl makes it difficult to
access, for example, a single column, or a two-dimensional slice,
without writing lots of extra code.

Array::2D uses "row" for the first dimension, and "column" or
"col"  for the second dimension. This does mean that the order
of (row, column) is the opposite of the usual (x,y) algebraic order.

Because this object is just an array of arrays, most of the methods
referring to rows are here mainly for completeness, and aren't 
much more useful than the native Perl construction (e.g., `$array2d->last_row()` is just a slower way of doing `$#{$array2d}`.) They will also typically be much slower.

On the other hand, most of the methods referring to columns are useful,
since there's no simple way of fetching a column or columns in Perl.  

Notably, the column
methods are careful, when a row doesn't have an entry, to to fill out
the column with undefined values up to the last defined value.
In other words, if you have a column in an array-of-arrays of five rows, 
and there's only a value in the fourth row, then that column, when
returned, will look like ( undef, undef, undef, 'value'), 
not just ('value').

In general, however, the array is not always fully padded out -- undefined
values are added at the beginning of each row to ensure that elements
have the correct column indices, but they do not necessarily have
values padded out to the highest column.  For example, the following would
be valid:

    [
     [ undef, 1, 2 ],
     [     3  ],
     [     4, 6 ],
    ]

The columns would be returned as (undef, 3, 4), (1, undef, 6), and (2). 

The `prune()` method will eliminate excess padding.  The `pad()` method
will pad out the object to the highest row and column with a defined value.

(Padding state is not guaranteed to be consistent because the object
is designed to allow standard Perl constructs to apply to it, and those
do not preserve padding state.)

# METHODS

Some general notes:

- In all cases where an array of arrays is specified as an argument 
(_aoa\_ref_), this can be either an Array::2D object or a regular  
array of arrays data structure that is not an object. 
- Where rows are columns are removed from the object (as with any of the 
`pop_*`, `shift_*`, `del_*` methods), time-consuming assemblage of
return values is ommitted in void context.
- Some care is taken to ensure that rows are not autovivified.  Normally, if the 
highest row in an arrayref-of-arrayrefs is 2, and a program
attempts to read the value of $aoa->\[3\]->\[$anything\], Perl will create 
an empty third row.  This module avoids autovification from just reading data.
This is the only advantage of methods like `element`, `row`, etc. compared
to regular Perl constructions.
- It is assumed that row and column indexes passed to the methods are integers.
If they are negative, they will count from the end instead of
the beginning, as in regular Perl array subscripts.  The behavior of the module
when anything else is passed in (strings, undef, floats, NaN, objects, etc.) is 
unspecified. Don't do that.

## CLASS METHODS

- **new( _row\_ref, row\_ref..._)**
- **new( _aoa\_ref_ )**

    Returns a new Array::2D object.  It accepts a list of array 
    references as arguments, which become the rows of the object.

    If it receives only one argument, and that argument is an array of
    arrays -- that is, a reference to an unblessed array, and in turn
    that array only contains references to unblessed arrays -- then the
    arrayrefs contained in that structure are made into the rows of a new
    Array::2D object.

    If you want it to bless an existing arrayref-of-arrayrefs, use
    `bless()`.  If you don't want to reuse the existing arrayrefs as
    the rows inside the object, use `clone()`.

    If you think it's possible that the detect-an-AoA-structure could
    give a false positive (you want a new object that might have only one row,
    where each entry in that row is an reference to an unblessed array),
    use `Array::2D-`bless ( \[ @your\_rows \] )>.

- **bless(_row\_ref, row\_ref..._)**
- **bless(_aoa\_ref_)**

    Just like new(), except that if passed a single arrayref which contains
    only other arrayrefs, it will bless the outer arrayref and return it. 
    This saves the time and memory needed to copy the rows.

    Note that this blesses the original array, so any other references to
    this data structure will become a reference to the object, too.

- **empty**

    Returns a new, empty Array::2D object.

- **new\_across(_chunksize, element, element, ..._)**

    Takes a flat list and returns it as an Array::2D object, 
    where each row has the number of elements specified. So, for example,

        Array::2D->new_across (3, qw/a b c d e f g h i j/)

    returns

        [ 
          [ a, b, c] ,
          [ d, e, f] ,
          [ g, h, i] ,
          [ j ],
        ]

- **new\_down(_chunksize, element, element, ..._)**

    Takes a flat list and returns it as an Array::2D object, 
    where each column has the number of elements specified. So, for
    example,

        Array::2D->new_down (3, qw/a b c d e f g h i j/)

    returns

        [ 
          [ a, d, g, j ] ,
          [ b, e, h ] ,
          [ c, f, i ] ,
        ]

- **new\_to\_term\_width (...)**

    A combination of _new\_down_ and _tabulate\_equal\_width_.  Takes three named
    arguments:

    - array => _arrayref_

        A one-dimensional list of scalars.

    - separator => _separator_

        A scalar to be passed to ->tabulate\_equal\_width(). The default is a single space.

    - width => _width_

        The width of the terminal. If not specified, defaults to 80.

    The method determines the number of columns required, creates an
    Array::2D object of that number of columns using new\_down, and
    then returns first the object and then the results of ->tabulate\_equal\_width() on
    that object.

- **new\_from\_tsv(_tsv\_string, tsv\_string..._)**

    Returns a new object from a string containing tab-delimited values. 
    The string is first split into lines (delimited by carriage returns,
    line feeds, a CR/LF pair, or other characters matching Perl's \\R) and
    then split into values by tabs.

    If multiple strings are provided, they will be considered additional
    lines. So, one can pass the contents of an entire TSV file, the series
    of lines in the TSV file, or a combination of two.

- **new\_from\_xlsx(_xlsx\_filespec, sheet\_requested_)**

    Returns a new object from a worksheet in an Excel XLSX file, consisting
    of the rows and columns of that sheet. The _sheet\_requested_ parameter
    is passed directly to the `->worksheet` method of 
    `Spreadsheet::ParseXLSX`, which accepts a name or an index. If nothing
    is passed, it requests sheet 0 (the first sheet).

- **new\_from\_file(_filespec_)**

    Returns a new object from a file on disk. If the file has the extension
    .xlsx, passes that file to `new_from_xlsx`. If the file has the
    extension .txt, .tab, or .tsv, slurps the file in memory and passes the
    result to `new_from_tsv`.

    (Future versions might accept CSV files as well, and test the contents
    of .txt files to see whether they are comma-delimited or
    tab-delimited.)

## CLASS/OBJECT METHODS

All class/object methods can be called as an object method on a blessed
Array::2D object:

    $self->clone();

Or as a class method, if one supplies the array of arrays as the first
argument:

    Array::2D->clone($self);

In the latter case, the array of arrays need not be blessed.

- **clone()**

    Returns new object which has copies of the data in the 2D array object.
    The 2D array will be different, but if any of the elements of the 2D
    array are themselves references, they will refer to the same things as
    in the original 2D array.

- **unblessed()**

    Returns an unblessed array containing the same rows as the 2D
    array object. If called as a class method and given an argument that is
    already unblessed, will return the argument. Otherwise will create
    a new, unblessed array.

    This is usually pointless, as Perl lets you ignore the object-ness of
    any object and access the data inside, but sometimes certain modules
    don't like to break object encapsulation, and this will allow getting
    around that.

    Note that while modifying the elements inside the rows will modify the 
    original 2D array, modifying the outer arrayref will not (unless
    that arrayref was not blessed in the first place). So:

        my $unblessed = $array2d->unblessed;

        $unblessed->[0][0] = 'Up in the corner'; 
            # modifies original object

        $unblessed->[0] = [ 'Up in the corner ' , 'Yup']; 
           # does not modify original object

    This can be confusing, so it's best to avoid modifying the result of
    `unblessed`. Use `clone_unblessed` instead.

- **clone\_unblessed()**

    Returns a new, unblessed, array of arrays containing copies of the data
    in the 2D array object.

    The array of arrays will be different, but if any of the elements of
    the  2D array are themselves references, they will refer to the same
    things as in the original 2D array.

- **is\_empty()**

    Returns a true value if the object is empty, false otherwise.

- **height()**

    Returns the number of rows in the object.  

- **width()**

    Returns the number of columns in the object. (The number of elements in
    the longest row.)

- **last\_row()**

    Returns the index of the last row of the object.  If the object is
    empty, returns -1.

- **last\_col()**

    Returns the index of the last column of the object. (The index of the
    last element in the longest row.) If the object is
    empty, returns -1.

- **element(_row\_idx, col\_idx_)**

    Returns the element in the given row and column. A slower way of
    saying `$array2d->[_row_idx_][_col_idx_]`, except that it avoids
    autovivification.  Like that construct, it will return undef if the element
    does not already exist.

- **row(_row\_idx_)**

    Returns the elements in the given row.  A slower way of saying  `@{$array2d->[_row_idx_]}`, except that it avoids autovivification.

- **col(_col\_idx_)**

    Returns the elements in the given column.

- **rows(_row\_idx, row\_idx..._)**

    Returns a new Array::2D object with all the columns of the 
    specified rows.

    Note that duplicates are not de-duplicated, so the result of
    $obj->rows(1,1,1) will be three copies of the same row.

- **cols(_col\_idx_, &lt;col\_idx**...)>

    Returns a new Array::2D object with the specified columns. This is transposed
    from the original array's order, so each column requested will be in its own
    row.

    Note that duplicates are not de-duplicated, so the result of
    $obj->cols(1,1,1) will retrieve three copies of the same column.

- **slice\_cols(_col\_idx_, &lt;col\_idx**...)>

    Returns a new Array::2D object with the specified columns of each row.
    Unlike `slice()`, the result of this method is not transposed.

    Note that duplicates are not de-duplicated, so the result of
    $obj->cols(1,1,1) will retrieve three copies of the same column.

- **slice(_row\_idx\_from, col\_idx\_to, col\_idx\_from, col\_idx\_to_)**

    Takes a two-dimensional slice of the object; like cutting a rectangle
    out of the object.

    In void context, alters the original object, which then will contain
    only the area specified; otherwise, creates a new Array::2D 
    object and returns the object.

    Negative indicies are treated as though they mean that many from the end:
    the last item is -1, the second-to-last is -2, and so on. 

    Slices are always returned in the order of the original object, so 
    $obj->slice(0,1,0,1) is the same as $obj->slice(1,0,1,0).

- **set\_element(_row\_idx, col\_idx, value_)**

    Sets the element in the given row and column to the given value. 
    Just a slower way of saying 
    `$array2d->[_row_idx_][_col_idx_] = _value_`.

- **set\_row(_row\_idx , value, value..._)**

    Sets the given row to the given set of values.
    A slower way of saying  `{$array2d->[_row_idx_] = [ @values ]`.

- **set\_col(_col\_idx, value, value..._)**

    Sets the given column to the given set of values.  If more values are given than
    there are rows, will add rows; if fewer values than there are rows, will set the 
    entries in the remaining rows to `undef`.

- **set\_rows(_start\_row\_idx, array\_of\_arrays_)**
- **set\_rows(_start\_row\_idx, row\_ref, row\_ref ..._)**

    Sets the rows starting at the given start row index to the rows given.
    So, for example, $obj->set\_rows(1, $row\_ref\_a, $row\_ref\_b) will set 
    row 1 of the object to be the elements of $row\_ref\_a and row 2 to be the 
    elements of $row\_ref\_b.

    The arguments after _start\_row\_idx_ are passed to `new()`, so it accepts
    any of the arguments that `new()` accepts.

- **set\_cols(_start\_col\_idx, col\_ref, col\_ref_...)**

    Sets the columns starting at the given start column index to the columns given.
    So, for example, $obj->set\_cols(1, $col\_ref\_a, $col\_ref\_b) will set 
    column 1 of the object to be the elemnents of $col\_ref\_a and column 2 to be the
    elements of $col\_ref\_b.

- **set\_slice(_first\_row, first\_col, array\_of\_arrays_)**
- **set\_slice(_first\_row, first\_col, row\_ref, row\_ref..._)**

    Sets a rectangular segment of the object to have the values of the supplied
    rows or array of arrays, beginning at the supplied first row and first column.
    The arguments after the row and columns are passed to `new()`, so it accepts
    any of the arguments that `new()` accepts.

- **shift\_row()**

    Removes the first row of the object and returns a list  of the elements
    of that row.

- **shift\_col()**

    Removes the first column of the object and returns a list of the
    elements of that column.

- **pop\_row()**

    Removes the last row of the object and returns a list of the elements
    of that row.

- **pop\_col()**

    Removes the last column of the object and returns  a list of the
    elements of that column.

- **push\_row(_element, element..._)**

    Adds the specified elements as the new final row. Returns the new 
    number of rows.

- **push\_col(_element, element..._)**

    Adds the specified elements as the new final column. Returns the new 
    number of columns.

- **push\_rows(_aoa\_ref_)**
- **push\_rows(_row\_ref, row\_ref..._)**

    Takes the specified array of arrays and adds them as new rows after the
    end of the existing rows. Returns the new number of rows.

    The arguments are passed to `new()`, so it accepts
    any of the arguments that `new()` accepts.

- **push\_cols(_col\_ref, col\_ref..._)**

    Takes the specified array of arrays and adds them as new columns, after
    the end of the existing columns. Returns the new number of columns.

- **unshift\_row(_element, element..._)**

    Adds the specified elements as the new first row. Returns the new 
    number of rows.

- **unshift\_col(_element, element..._)**

    Adds the specified elements as the new first column. Returns the new 
    number of columns.

- **unshift\_rows(_aoa\_ref_)**
- **unshift\_rows(_row\_ref, row\_ref..._)**

    Takes the specified array of arrays and adds them as new rows before
    the beginning of the existing rows. Returns the new number of rows.

    The arguments are passed to `new()`, so it accepts
    any of the arguments that `new()` accepts.

- **unshift\_cols(_col\_ref, col\_ref..._)**

    Takes the specified array of arrays and adds them as new columns,
    before the beginning of the existing columns. Returns the new number of
    columns.

- **ins\_row(_row\_idx, element, element..._)**

    Adds the specified elements as a new row at the given index. Returns
    the new number of rows.

- **ins\_col(_col\_idx, element, element..._)**

    Adds the specified elements as a new column at the given index. Returns
    the new number of columns.

- **ins\_rows(_row\_idx, aoa\_ref_)**

    Takes the specified array of arrays and inserts them as new rows at the
    given index.  Returns the new number of rows.

    The arguments after the row index are passed to `new()`, so it accepts
    any of the arguments that `new()` accepts.

- **ins\_cols(_col\_idx, col\_ref, col\_ref..._)**

    Takes the specified array of arrays and inserts them as new columns at
    the given index.  Returns the new number of columns.

- **del\_row(_row\_idx_)**

    Removes the row of the object specified by the index and returns a list
    of the elements of that row.

- **del\_col(_col\_idx_)**

    Removes the column of the object specified by the index and returns a
    list of the elements of that column.

- **del\_rows(_row\_idx_, _row\_idx_...)**

    Removes the rows of the object specified by the indices. Returns an
    Array::2D object of those rows.

- **del\_cols(_col\_idx_, _col\_idx_...)**

    Removes the columns of the object specified by the indices. Returns an
    Array::2D object of those columns.

- **transpose()**

    Transposes the object: the elements that used to be in rows are now in
    columns, and vice versa.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **prune()**

    Occasionally an array of arrays can end up with final rows or columns
    that are entirely undefined. For example:

        my $obj = Array::2D->new ( [ qw/a b c/]  , [ qw/f g h/ ]);
        $obj->[0][4] = 'e';
        $obj->[3][0] = 'k';

        # a b c undef e
        # f g h
        # (empty)
        # k

        $obj->pop_row();
        $obj->pop_col();

        # a b c undef
        # f g h
        # (empty)

    That would yield an object with four columns, but in which the last
    column  and last row (each with index 3) consists of only undefined
    values.

    The `prune` method eliminates these entirely undefined or empty
    columns and rows at the end of the object.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **prune\_empty()**

    Like `prune`, but treats not only undefined values as blank, but also 
    empty strings.

- **prune\_space()**

    Like `prune`, but treats not only undefined values as blank, but also 
    strings that are empty or that consist solely of white space.

- **prune\_callback(_code\_ref_)**

    Like `prune`, but calls the &lt;code\_ref> for each element, setting $\_ to
     each element. If the callback code returns true, the value is
    considered blank.

    For example, this would prune values that were undefined,  the empty
    string, or zero:

        my $callback = sub { 
            my $val = shift;
            ! defined $val or $val eq q[] or $val == 0;
        }
        $obj->prune_callback($callback);

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **pad(_value_)**

    The opposite of `prune()`, this pads out the array so every column
    has the same number of elements.  If provided, the added elements are
    given the value provided; otherwise, they are set to undef.

- **apply(_coderef_)**

    Calls the `$code_ref` for each element, aliasing $\_ to each element in
    turn. This allows an operation to be performed on every element.

    For example, this would lowercase every element in the array (assuming
    all values are defined):

        $obj->apply(sub {lc});

    If an entry in the array is undefined, it will still be passed to the
    callback.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

    For each invocation of the callback, @\_ is set to the row and column
    indexes (0-based).

- **trim()**

    Removes white space, if present, from the beginning and end  of each
    element in the array.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **trim\_right()**

    Removes white space from the end of each element in the array.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **define()**

    Replaces undefined values with the empty string.

    In void context, alters the original object. Otherwise, creates a new
    Array::2D object and returns the object.

- **hash\_of\_rows(_col\_idx_)**

    Creates a hash reference.  The keys are the values in the specified
    column of the array. The values are arrayrefs containing the elements
    of the rows of the array, with the value in the key column removed.

    If the key column is not specified, the first column is used for the
    keys.

    So:

        $obj = Array::2D->new([qw/a 1 2/],[qw/b 3 4/]);
        $hashref = $obj->hash_of_rows(0);
        # $hashref = { a => [ '1' , '2' ]  , b => [ '3' , '4' ] }

- **hash\_of\_row\_elements(_key\_column\_idx, value\_column\_idx_)**

    Like `hash_of_rows`, but accepts a key column and a value column, and
    the values are not whole rows but only single elements.

    So:

        $obj = Array::2D->new([qw/a 1 2/],[qw/b 3 4/]);
        $hashref = $obj->hash_of_row_elements(0, 1);
        # $hashref = { a => '1' , b => '3' }

    If neither key column nor value column are specified, column 0 will be
    used for the key and the column 1 will be used for the value.

    If the key column is specified but the value column is not, then the
    first column that is not the key column will be used as the value
    column. (In other words, if the key column is column 0, then column 1
    will be used as the value; otherwise column 0 will be used as the
    value.)

- **tabulate(_separator_)**

    Returns an arrayref of strings, where each string consists of the
    elements of each row, padded with enough spaces to ensure that each
    column has a consistent width.

    The columns will be separated by whatever string is passed to
    `tabulate()`.  If nothing is passed, a single space will be used.

    So, for example,

        $obj = Array::2D->new([qw/a bbb cc/],[qw/dddd e f/]);
        $arrayref = $obj->tabulate();

        # $arrayref = [ 'a    bbb cc' ,
                        'dddd e   f'] ;

    If the `Unicode::GCString|Unicode::GCString` module can be loaded,
    its `columns` method will be used to determine the width of each
    character. This will treat composed accented characters and
    double-width Asian characters correctly.

- **tabulated(_separator_)**

    Like `tabulate()`, but returns the data as a single string, using
    line feeds as separators of rows, suitable for sending to a terminal.

- **tabulate\_equal\_width(_separator_)**

    Like `tabulate()`, but instead of each column having its own width,
    all columns have the same width.

- **tsv(_headers_)**

    Returns a single string with the elements of each row delimited by
    tabs, and rows delimited by line feeds.

    If there are any arguments, they will be used first as the first
    row of text. The idea is that these will be the headers of the
    columns. It's not really any different than putting the column
    headers as the first element of the data, but frequently these are
    stored separately. If there is only one element and it is a reference
    to an array, that array will be used as the first row of text.

    If tabs, carriage returns, or line feeds are present in any element,
    they will be replaced by the Unicode visible symbols for tabs (U+2409),
    line feeds (U+240A), or carriage returns (U+240D). This generates a
    warning.  (In the future, this may change to the Replacement Character, 
    U+FFFD.)

- **xlsx(...)**

    Accepts a file specification and creates a new Excel XLSX file at that 
    location, with one sheet, containing the data in the 2D array.

    This method uses named parameters.

    - output\_file

        This mandatory parameter contains the file specification.

    - headers

        This parameter is optional. If present, it contains an array reference
        to be used as the first row in the Excel file.

        The idea is that these will be the headers of the columns. It's not
        really any different than putting the column headers as the first
        element of the data, but frequently these are stored separately. At
        this point no attempt is made to make them bold or anything like that.

    - format

        This parameter is optional. If present, it contains a hash reference,
        with format parameters as specified by Excel::Writer::XLSX.

- **&lt;file(...) **>

    Accepts a file specification and creates a new file at that  location
    containing the data in the 2D array.

    This method uses named parameters.

    - type

        This parameter is the file's type. Currently, the types recognized are
        'tsv' for tab-separated values, and 'xlsx' for Excel XLSX. If the type
        is not given, it attempts to determine the type from the file
        extension, which can be (case-insensitively) 'xlsx' for Excel XLSX
        files  or 'tab', 'tsv' or 'txt' for  tab-separated value files.

    - output\_file

        This mandatory parameter contains the file specification.

    - headers

        This parameter is optional. If present, it contains an array reference
        to be used as the first row in the ouptut file.

        The idea is that these will be the headers of the columns. It's not
        really any different than putting the column headers as the first
        element of the data, but frequently these are stored separately.

    - type

# DIAGNOSTICS

## ERRORS

- Arguments to Array::2D->new or Array::2D->blessed must be unblessed arrayrefs (rows)

    A non-arrayref, or blessed object (other than an Array::2D object), was 
    passed to the new constructor.

- Sheet $sheet\_requested not found in $xlsx in Array::2D->new\_from\_xlsx

    Spreadsheet::ParseExcel returned an error indicating that the sheet
    requested was not found.

- File type unrecognized in $filename passed to Array::2D->new\_from\_file

    A file other than an Excel (XLSX) or tab-delimited text files (with
    tab,  tsv, or txt extensions) are recognized in ->new\_from\_file.

- No file specified in Array::2D->new\_from\_file
- No file specified in Array::2D->new\_from\_xlsx

    No filename, or a blank filename, was passed to these methods.

## WARNINGS

- Tab character found in array during Array::2D->tsv; converted to visible symbol
- Line feed character found in array during Array::2D->tsv; converted to visible symbol
- Carriage return character found in array during Array::2D->tsv; converted to visible symbol

    An invalid character for TSV data was found in the array when creating 
    TSV data. It was converted to the Unicode visible symbol for that
    character, but this warning was issued.

# TO DO

- Add CSV (and possibly other file type) support to new\_from\_file.

# SEE ALSO

The [Data::Table](https://metacpan.org/pod/Data::Table) module on CPAN provides a more conventionally
opaque object that does many of the same things as this module.

# DEPENDENCIES

- Perl 5.8.1 or higher
- List::MoreUtils
- Params::Validate
- File::Slurper
- Spreadsheet::ParseXLSX
- Excel::Writer::XLSX

    The last three are required only by those methods that use them 
    (`new_from_tsv`, `new_from_xlsx`, and `xlsx` respectively).

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
