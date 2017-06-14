package Array::2D;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.001_001";
$VERSION = eval $VERSION;

# core modules
use Carp;
use List::Util(qw/any all max min none/);
use POSIX (qw/floor ceil/);
use Scalar::Util(qw/reftype blessed/);

# non-core modules
use List::MoreUtils(qw/natatime/);
use Params::Validate(qw/validate ARRAYREF HASHREF/);

# this is a deliberately non-encapsulated object that is just
# an array of arrays (AoA).
# The object can be treated as an ordinary array of arrays,
# or have methods invoked on it

### Test for Ref::Util and if present, use it
BEGIN {
    my $impl = $ENV{PERL_ARRAY_2D_NO_REF_UTIL}
      || our $NO_REF_UTIL;

    if ( !$impl && eval { require Ref::Util; 1 } ) {
        Ref::Util->import('is_plain_arrayref');
    }
    else {
        *is_plain_arrayref = sub { ref( $_[0] ) eq 'ARRAY' };
    }
}

### Test for Unicode::GCString and if present, use it

### First, the variable $text_columns_cr is declared.
### Then, it is set to a reference to code that
###    a) determines what the future text_columns code should be,
###    b) sets the variable $text_column_cr to point to that new code, and
###    c) then jumps to that new code.

### Thus the first time it's run, it basically redefines itself
### to be the proper routine (either one with or without Unicode::GCString).

my $text_columns_cr;
$text_columns_cr = sub {

    my $impl = $ENV{PERL_ARRAY_2D_NO_GCSTRING}
      || our $NO_GCSTRING;

    if ( !$impl && eval { require Unicode::GCString; 1 } ) {
        $text_columns_cr = sub {
            return Unicode::GCString->new("$_[0]")->columns;
            # explicit stringification is necessary
            # since Unicode::GCString doesn't automatically
            # stringify numbers
        };
    }
    else {
        $text_columns_cr = sub {
            return length( $_[0] );
        };
    }
    goto $text_columns_cr;

};

#################
### Class methods

sub empty {
    my $class = shift;
    return CORE::bless [], $class;
}

sub new {

    if (    @_ == 2
        and is_plain_arrayref( $_[1] )
        and all { is_plain_arrayref($_) } @{ $_[1] } )
    {
        my $class = shift;
        my $aoa   = shift;

        my $self = [ @{$aoa} ];
        CORE::bless $self, $class;
        return $self;
    }

    goto &bless;

}

sub bless {

    my $class = shift;
    my $self;

    my @rows = @_;

    if ( @rows == 0 ) {    # if no arguments, new anonymous AoA
        return $class->empty;
    }

    if ( @rows == 1 ) {
        my $blessing = blessed( $rows[0] );
        if ( defined($blessing) and $blessing eq $class ) {
            # already an object
            $self = $rows[0];
            return $self;
        }

        if ( is_plain_arrayref( $rows[0] )
            and all { is_plain_arrayref($_) } @{ $rows[0] } )
        {
            my $self = $rows[0];
            CORE::bless $self, $class;
            return $self;
        }
    }

    $self = [@rows];

    if ( any { not is_plain_arrayref($_) } @rows ) {
        croak
"Arguments to $class->new or $class->blessed must be unblessed arrayrefs (rows)";
    }

    CORE::bless $self, $class;
    return $self;

} ## tidy end: sub bless

sub new_across {
    my $class = shift;

    my $quantity = shift;
    my @values   = @_;

    my $self;
    my $it = natatime( $quantity, @values );
    while ( my @vals = $it->() ) {
        push @{$self}, [@vals];
    }

    CORE::bless $self, $class;
    return $self;

}

sub new_down {
    my $class = shift;

    my $quantity = shift;
    my @values   = @_;

    my $self;
    my $it = natatime( $quantity, @values );

    while ( my @vals = $it->() ) {
        for my $i ( 0 .. $#vals ) {
            push @{ $self->[$i] }, $vals[$i];
        }
    }

    CORE::bless $self, $class;
    return $self;

}

sub new_to_term_width {

    my $class  = shift;
    my %params = validate(
        @_,
        {   array     => { type    => ARRAYREF },
            width     => { default => 80 },
            separator => { default => q[ ] },
        }
    );

    my $array = $params{array};

    my $separator = $params{separator};
    my $sepwidth  = $text_columns_cr->($separator);
    my $colwidth  = $sepwidth + max( map { $text_columns_cr->($_) } @$array );
    my $cols      = floor( ( $params{width} + $sepwidth ) / ($colwidth) ) || 1;

    # add sepwidth there to compensate for the fact that we don't actually
    # print the separator at the end of the line

    my $rows = ceil( @$array / $cols );

    my $obj = $class->new_down( $rows, @$array );

    my $tabulated = $obj->tabulate_equal_width($separator);

    return $obj, $tabulated;

} ## tidy end: sub new_to_term_width

############################################
#### Class methods - new from various files

sub new_from_tsv {
    my $class = shift;
    my @lines = map { split(/\R/) } @_;
    my $self  = [ map { [ split(/\t/) ] } @lines ];

    CORE::bless $self, $class;
    return $self;
}

sub new_from_xlsx {
    my $class           = shift;
    my $xlsx_filespec   = shift;
    my $sheet_requested = shift || 0;

    # || handles empty strings

    croak "No file specified in " . __PACKAGE__ . '->new_from_xlsx'
      unless $xlsx_filespec;

    require Spreadsheet::ParseXLSX;    ### DEP ###

    my $parser   = Spreadsheet::ParseXLSX->new;
    my $workbook = $parser->parse($xlsx_filespec);

    if ( !defined $workbook ) {
        croak $parser->error();
    }

    my $sheet = $workbook->worksheet($sheet_requested);

    if ( !defined $sheet ) {
        croak "Sheet $sheet_requested not found in $xlsx_filespec in "
          . __PACKAGE__
          . '->new_from_xlsx';
    }

    my ( $minrow, $maxrow ) = $sheet->row_range();
    my ( $mincol, $maxcol ) = $sheet->col_range();

    my @rows;

    foreach my $row ( $minrow .. $maxrow ) {

        my @cells = map { $sheet->get_cell( $row, $_ ) } ( $mincol .. $maxcol );

        foreach (@cells) {
            if ( defined $_ ) {
                $_ = $_->value;
            }
            else {
                $_ = q[];
            }
        }

        push @rows, \@cells;

    }

    return $class->bless( \@rows );

} ## tidy end: sub new_from_xlsx

my $filetype_from_ext_r = sub {
    my $filespec = shift;
    return unless $filespec;

    my ($ext) = $filespec =~ m/
                      [.]     # a dot
                      ([^.]+) # one or more non-dot characters
                      \z      # end of the string
                      /x;

    my $fext = fc($ext);

    if ( $fext eq fc('xlsx') ) {
        return 'xlsx';
    }

    if ( any { $fext eq fc($_) } qw/tsv tab txt/ ) {
        return 'tsv';
    }

    return;

};

sub new_from_file {
    my $class    = shift;
    my $filespec = shift;
    my $filetype = shift || $filetype_from_ext_r->($filespec);

    croak "Cannot determine type of $filespec in "
      . __PACKAGE__
      . '->new_from_file'
      unless $filetype;

    if ( $filetype eq 'xlsx' ) {
        return $class->new_from_xlsx($filespec);
    }

    if ( $filetype eq 'tsv' ) {
        require File::Slurper;    ### DEP ###
        my $tsv = File::Slurper::read_text($filespec);
        return $class->new_from_tsv($tsv);
    }

    croak "File type $filetype unrecognized in "
      . __PACKAGE__
      . '->new_from_file';

} ## tidy end: sub new_from_file

################################################################
### shim allowing being called as either class or object method

my $invocant_cr = sub {
    my $invocant = shift;
    my $blessing = blessed $invocant;

    return ( $blessing, $invocant ) if defined $blessing;
    # invocant is an object blessed into the $blessing class

    my $object = shift;
    return ( $invocant, $object ) if defined $object;
    # invocant is a class

    croak 'No object passed to ' . ( caller(1) )[3];

};

#################################
### Object methods - construction

sub clone {
    my ( $class, $self ) = &$invocant_cr;
    my $new = [ map { [ @{$_} ] } @{$self} ];
    CORE::bless $new, $class;
    return $new;
}

sub unblessed {
    my ( $class, $self ) = &$invocant_cr;
    return $self if not blessed $self;
    my $new = [ @{$self} ];
    return $new;
}

sub clone_unblessed {
    my ( $class, $self ) = &$invocant_cr;
    my $new = [ map { [ @{$_} ] } @{$self} ];
    return $new;
}

##################################################
### find the last index, or the number of elements
### (like scalar @array or $#array for 1D arrays)

sub is_empty {
    my ( $class, $self ) = &$invocant_cr;
    return not( scalar @$self );
}

sub height {
    my ( $class, $self ) = &$invocant_cr;
    return scalar @$self;
}

sub width {
    my ( $class, $self ) = &$invocant_cr;
    return 0 unless @{$self};
    return max( map { scalar @{$_} } @{$self} );
}

sub last_row {
    my ( $class, $self ) = &$invocant_cr;
    return -1 unless @{$self};
    return $#{$self};
}

sub last_col {
    my ( $class, $self ) = &$invocant_cr;
    return -1 unless @{$self};
    return max( map { $#{$_} } @{$self} );
}

#########################################
### Readers for elements, rows and columns

sub element {
    my ( $class, $self ) = &$invocant_cr;
    my $rowidx = shift;
    return undef if $rowidx > $#{$self};
    my $colidx = shift;
    return undef if $colidx > $#{ $self->[$rowidx] };
    return $self->[$rowidx][$colidx];
}

sub row {
    my ( $class, $self ) = &$invocant_cr;
    my $rowidx = shift || 0;
    return () if $rowidx > $#{$self};
    my @row = @{ $self->[$rowidx] };
    pop @row while @row and not defined $row[-1];
    return @row;
}

sub col {
    my ( $class, $self ) = &$invocant_cr;
    return () if $class->is_empty($self);
    my $colidx = shift || 0;
    if ( $colidx < 0 ) {
        $colidx = $colidx + $class->last_col($self) + 1;
    }
    my @col = map { $colidx <= $#{$_} ? $_->[$colidx] : undef } @{$self};
    # the element if it's not less than the highest column of that row,
    # otherwise undef
    pop @col while @col and not defined $col[-1];
    return @col;
}

sub rows {
    my ( $class, $self ) = &$invocant_cr;
    my @row_indices = @_;
    my $rows
      = $class->new( map { $#{$self} <= $_ ? $self->[$_] : [] } @row_indices );
    # the row if it's less than or equal to the highest row idx, othewise
    # an empty ref
    $rows->prune();
    return $rows;
}

sub cols {
    my ( $class, $self ) = &$invocant_cr;

    my @col_indices = @_;
    my $cols        = $class->empty;
    foreach my $colidx (@col_indices) {
        push @$cols, [ map { $self->[$_][$colidx] } 0 .. $#{$self} ];
    }
    $cols->prune;
    return $cols;
}

sub slice {
    my ( $class, $self ) = &$invocant_cr;

    my ( $firstcol, $lastcol, $firstrow, $lastrow ) = @_;

    ( $firstrow, $lastrow ) = ( $lastrow, $firstrow )
      if $lastrow < $firstrow;

    my $self_lastrow = $class->last_row($self);

    foreach my $row ( $firstrow, $lastrow ) {
        next unless $row < 0;
        $row += $class->height($self);
    }

    # if it's specifying an area entirely off the beginning or end
    # of the array, return empty
    if ( $lastrow < 0 or $self_lastrow < $firstrow ) {
        return $class->empty() if defined wantarray;
        @{$self} = ();
        return;
    }

    # otherwise, if it's at least partially in the array, set the bounds
    # to be within the array.
    $lastrow  = $self_lastrow if $self_lastrow < $lastrow;
    $firstrow = 0             if $firstrow < 0;

    my $rows = $class->rows( $self, $firstrow .. $lastrow );

    # if negative, get the column from the end (of original, not of these rows)
    foreach my $col ( $firstcol, $lastcol ) {
        next unless $col < 0;
        $col += $class->width($self);
    }

    ( $firstcol, $lastcol ) = ( $lastcol, $firstcol )
      if $lastcol < $firstcol;

    # if it's specifying an area entirely off the beginning or end
    # of the array, return empty
    if ( $lastcol < 0 or $self_lastrow < $firstrow ) {
        return $class->empty() if defined wantarray;
        @{$self} = ();
        return;
    }

    # otherwise, if it's at least partially in the array, set the bounds
    # to be within the rows.
    $firstcol = 0 if $firstcol < 0;
    my $rows_lastcol = $class->last_col($rows);
    $lastcol = $rows_lastcol if $rows_lastcol < $lastcol;

    my $new = $class->cols( $rows, $firstcol .. $lastcol );
    return $new if defined wantarray;
    @{$self} = @{$new};
    return;

} ## tidy end: sub slice

#########################################
### Writers for elements, rows and columns

sub set_element {
    my ( $class, $self ) = &$invocant_cr;
    my $rowidx = shift;
    my $colidx = shift;
    $self->[$rowidx][$colidx] = shift;
    return;
}

sub set_row {
    my ( $class, $self ) = &$invocant_cr;
    my $rowidx = shift || 0;
    my @elements = @_;
    $self->[$rowidx] = \@elements;
    return;
}

sub set_col {
    my ( $class, $self ) = &$invocant_cr;
    my $colidx   = shift;
    my @elements = @_;
    for my $rowidx ( 0 .. max( $self->last_row, $#elements ) ) {
        $self->[$rowidx][$colidx] = $elements[$rowidx];
    }
}

sub set_rows {
    my ( $class, $self ) = &$invocant_cr;
    my $self_start_rowidx = shift;
    my $given             = $class->new(@_);
    my @given_rows        = @{$given};
    for my $given_rowidx ( 0 .. $#given_rows ) {
        my @elements = @{ $given_rows[$given_rowidx] };
        $self->[ $self_start_rowidx + $given_rowidx ] = \@elements;
    }
    return;
}

sub set_cols {
    my ( $class, $self ) = &$invocant_cr;
    my $self_start_colidx = shift;
    my @given_cols        = @_;

    foreach my $given_colidx ( 0 .. $#given_cols ) {
        my @given_elements = @{ $given_cols[$given_colidx] };
        $self->set_col( $self_start_colidx + $given_colidx, @given_elements );
    }
}

sub set_slice {
    my ( $class, $self ) = &$invocant_cr;

    my $class_firstrow = shift;
    my $class_firstcol = shift;

    my $slice          = $class->new(@_);
    my $slice_last_row = $slice->last_row;
    my $slice_last_col = $slice->last_col;

    for my $rowidx ( 0 .. $slice_last_row ) {
        for my $colidx ( 0 .. $slice_last_col ) {
            $self->[ $class_firstrow + $rowidx ][ $class_firstcol + $colidx ]
              = $slice->[$rowidx][$colidx];
        }
    }

    return;

} ## tidy end: sub set_slice

##############################
### push, pop, shift, unshift

sub shift_row {
    my ( $class, $self ) = &$invocant_cr;
    return () unless @{$self};
    my @row = @{ shift @{$self} };
    pop @row while @row and not defined $row[-1];
    return @row;
}

sub shift_col {
    my ( $class, $self ) = &$invocant_cr;
    my @col = map { shift @{$_} } @{$self};
    pop @col while @col and not defined $col[-1];
    return @col;
}

sub pop_row {
    my ( $class, $self ) = &$invocant_cr;
    return () unless @{$self};
    my @row = @{ pop @{$self} };
    pop @row while @row and not defined $row[-1];
    return @row;
}

sub pop_col {
    my ( $class, $self ) = &$invocant_cr;
    my $last_col = $class->last_col($self);
    return $class->del_col( $self, $last_col );
}

sub push_row {
    my ( $class, $self ) = &$invocant_cr;
    my @col_values = @_;
    return push @{$self}, \@col_values;
}

sub push_col {
    my ( $class, $self ) = &$invocant_cr;
    my @col_values = @_;
    my $col_idx    = $class->last_col($self);

    if ( $col_idx == -1 ) {
        @{$self} = map { [$_] } @col_values;
        return $class->width($self);
    }

    my $last_row = max( $class->last_row($self), $#col_values );
    my $last_col = $class->last_col($self);

    for my $row_index ( 0 .. $last_row ) {
        my $row_r = $self->[$row_index];
        if ( not defined $row_r ) {
            $row_r = $self->[$row_index] = [];
        }
        $row_r->[ $last_col + 1 ] = $col_values[$row_index];
    }

    return $class->width($self);

} ## tidy end: sub push_col

sub push_rows {
    my ( $class, $self ) = &$invocant_cr;
    my $rows = $class->new(@_);
    return push @{$self}, @$rows;
}

sub push_cols {
    my ( $class, $self ) = &$invocant_cr;
    my @cols    = @_;
    my $col_idx = $class->last_col($self);

    if ( $col_idx == -1 ) {
        @{$self} = map { [ @{$_} ] } @{$self};
        return $class->width($self);
    }

    my $last_row = max( $class->last_row($self), $#cols );
    my $last_col = $class->last_col($self);

    for my $row_index ( 0 .. $last_row ) {
        my $row_r = $self->[$row_index];
        if ( not defined $row_r ) {
            $row_r = $self->[$row_index] = [];
        }
        $#{$row_r} = $last_col;    # pad out
        push @{$row_r}, @{ $cols[$row_index] };
    }

    return $class->width($self);

} ## tidy end: sub push_cols

sub unshift_row {
    my ( $class, $self ) = &$invocant_cr;
    my @col_values = @_;
    return unshift @{$self}, \@col_values;
}

sub unshift_col {
    my ( $class, $self ) = &$invocant_cr;
    my @col_values = @_;
    return $class->ins_col( $self, 0, @col_values );
}

sub unshift_rows {
    my ( $class, $self ) = &$invocant_cr;
    my $given = $class->new(@_);
    return unshift @{$self}, @$given;
}

sub unshift_cols {
    my ( $class, $self ) = &$invocant_cr;
    my @cols = @_;
    return $class->ins_cols( $self, 0, @cols );
}

#################################
### insert rows or columns by index

sub ins_row {
    my ( $class, $self ) = &$invocant_cr;
    my $row_idx = shift;
    my @row     = @_;

    splice( @{$self}, $row_idx, 0, \@row );
    return scalar @{$self};
}

sub ins_col {
    my ( $class, $self ) = &$invocant_cr;
    my $col_idx = shift;
    my @col     = @_;

    my $last_row = max( $class->last_row($self), $#col );

    for my $row_idx ( 0 .. $last_row ) {
        splice( @{ $self->[$row_idx] }, $col_idx, 0, $col[$row_idx] );
    }

    return $class->width($self);
}

sub ins_rows {
    my ( $class, $self ) = &$invocant_cr;
    my $row_idx = shift;
    my $given   = $class->new(@_);

    splice( @{$self}, $row_idx, 0, @$given );
    return scalar @{$self};
}

sub ins_cols {
    my ( $class, $self ) = &$invocant_cr;
    my $col_idx = shift;
    my @cols    = @_;

    my $last_row = max( $class->last_row($self), map { $#{$_} } @cols );

    for my $row_idx ( 0 .. $last_row ) {
        for my $col (@cols) {
            splice( @{ $self->[$row_idx] }, $col_idx, 0, $col->[$row_idx] );
        }
    }
    return $class->width($self);
}

#################################
### delete rows or columns by index

sub del_row {
    my ( $class, $self ) = &$invocant_cr;
    my $row_idx = shift;

    return () unless @{$self};

    my @deleted;
    if ( defined wantarray ) {
        @deleted = $class->row( $self, $row_idx );
    }

    splice( @{$self}, $row_idx, 1 );

    return @deleted if defined wantarray;
    return;
}

sub del_col {
    my ( $class, $self ) = &$invocant_cr;
    my $col_idx = @_;

    my @deleted;
    if ( defined wantarray ) {
        @deleted = $class->col( $self, $col_idx );
    }

    foreach my $row ( @{$self} ) {
        splice( @{$row}, $col_idx, 1 );
    }

    return @deleted if defined wantarray;
    return;
}

sub del_rows {
    my ( $class, $self ) = &$invocant_cr;
    my @row_idxs = @_;

    unless (@$self) {
        return $class->empty if defined wantarray;
        return;
    }

    my $deleted;
    if ( defined wantarray ) {
        $deleted = $class->rows( $self, @row_idxs );
    }

    foreach my $row_idx (@row_idxs) {
        splice( @{$self}, $row_idx, 1 );
    }

    return $deleted if defined wantarray;
    return;
} ## tidy end: sub del_rows

sub del_cols {
    my ( $class, $self ) = &$invocant_cr;
    my @col_idxs = @_;

    my $deleted;
    if ( defined wantarray ) {
        $deleted = $class->cols( $self, @col_idxs );
    }

    foreach my $col_idx ( reverse sort @_ ) {
        foreach my $row ( @{$self} ) {
            splice( @{$row}, $col_idx, 1 );
        }
    }

    return $deleted if defined wantarray;
    return;
}

##################################################
### Mutators. Modify object in void context; returns new object otherwise

sub transpose {
    my ( $class, $self ) = &$invocant_cr;

    unless ( @{$self} ) {
        return $class->empty if defined wantarray;
        return $self;
    }

    my $new = [];

    foreach my $col ( 0 .. $class->last_col($self) ) {
        push @{$new}, [ map { $_->[$col] } @{$self} ];
    }

    # non-void context: return new object
    if ( defined wantarray ) {
        CORE::bless $new, $class;
        return $new;
    }

    # void context: alter existing object
    @{$self} = @{$new};
    return;

} ## tidy end: sub transpose

sub prune {
    my ( $class, $self ) = &$invocant_cr;
    my $callback = sub { !defined $_ };
    return $class->prune_callback( $self, $callback );
}

sub prune_empty {
    my ( $class, $self ) = &$invocant_cr;
    my $callback = sub { !defined $_ or $_ eq q[] };
    return $class->prune_callback( $self, $callback );
}

sub prune_space {
    my ( $class, $self ) = &$invocant_cr;
    my $callback = sub { !defined $_ or m[\A \s* \z]x };
    return $class->prune_callback( $self, $callback );
}

sub prune_callback {
    my ( $class, $orig ) = &$invocant_cr;
    my $callback = shift;
    my $self;

    if ( defined wantarray ) {
        $self = $class->clone($orig);
    }
    else {
        $self = $orig;
    }

    # remove final blank rows
    while (
        @{$self}
        and (  !defined $self->[-1]
            or @{ $self->[-1] } == 0
            or all { $callback->() } @{ $self->[-1] } )
      )
    {
        pop @{$self};
    }

    # return if it's all blank
    return $self unless ( @{$self} );

    # remove final blank columns

    foreach my $row_r ( @{$self} ) {
        while ( @{$row_r} ) {
            local $_ = $row_r->[-1];
            last if not $callback->();
            pop @$row_r;
        }
    }

    return $self;
} ## tidy end: sub prune_callback

sub apply {
    my ( $class, $orig ) = &$invocant_cr;
    my $callback = shift;
    my $self;

    if ( defined wantarray ) {
        $self = $class->clone($orig);
    }
    else {
        $self = $orig;
    }

    for my $row ( @{$self} ) {
        for my $idx ( 0 .. $#{$row} ) {
            for ( $row->[$idx] ) {
                # localize $_ to $row->[$idx]. Autovivifies the row.
                $callback->( $row, $idx );
            }
        }
    }
    return $self;
} ## tidy end: sub apply

sub trim {
    my ( $class, $self ) = &$invocant_cr;

    my $callback = sub {
        return unless defined;
        s/\A\s+//;
        s/\s+\z//;
        return;
    };

    return $class->apply( $self, $callback );
}

sub trim_right {
    my ( $class, $self ) = &$invocant_cr;

    my $callback = sub {
        return unless defined;
        s/\s+\z//;
        return;
    };

    return $class->apply( $self, $callback );
}

sub define {
    my ( $class, $self ) = &$invocant_cr;

    my $callback = sub {
        $_ //= q[];
    };
    return $class->apply( $self, $callback );
}

#################################################
### Transforming the object into something else

sub hash_of_rows {
    my ( $class, $self ) = &$invocant_cr;
    my $col = shift;

    my %hash;

    if ($col) {
        for my $row_r ( @{$self} ) {
            my @row = @{$row_r};
            my $key = splice( @row, $col, 1 );
            $hash{$key} = \@row;
        }
    }
    else {

        for my $row_r ( @{$self} ) {
            my @row = @{$row_r};
            my $key = shift @row;
            $hash{$key} = \@row;
        }

    }

    return \%hash;
} ## tidy end: sub hash_of_rows

sub hash_of_row_elements {
    my ( $class, $self ) = &$invocant_cr;

    my ( $keycol, $valuecol );
    if (@_) {
        $keycol = shift;
        $valuecol = shift // ( $keycol == 0 ? 1 : 0 );

        # $valuecol defaults to first column that is not the same as $keycol
    }
    else {
        $keycol   = 0;
        $valuecol = 1;
    }

    my %hash;
    for my $row_r ( @{$self} ) {
        $hash{ $row_r->[$keycol] } = $row_r->[$valuecol];
    }

    return \%hash;
} ## tidy end: sub hash_of_row_elements

sub tabulate_equal_width {
    my ( $class, $orig ) = &$invocant_cr;
    my $self = $class->define($orig);
    # makes a copy
    my $separator = shift // q[ ];

    my %width_of;
    $width_of{$_} = $text_columns_cr->($_) foreach $class->flattened($self);

    my $colwidth = max( values %width_of );

    my @lines;

    foreach my $fields ( @{$self} ) {

        for my $j ( 0 .. $#{$fields} - 1 ) {
            $fields->[$j]
              .= q[ ] x ( $colwidth - $width_of{ $fields->[$j] } );
        }
        push @lines, join( $separator, @$fields );

    }

    return \@lines;

} ## tidy end: sub tabulate_equal_width

sub tabulate {
    my ( $class, $orig ) = &$invocant_cr;
    my $self = $class->define($orig);

    my $separator = shift // q[ ];
    my @length_of_col;

    foreach my $row ( @{$self} ) {

        my @fields = @{$row};
        for my $this_col ( 0 .. $#fields ) {
            my $thislength = $text_columns_cr->( $fields[$this_col] ) // 0;
            if ( not $length_of_col[$this_col] ) {
                $length_of_col[$this_col] = $thislength;
            }
            else {
                $length_of_col[$this_col]
                  = max( $length_of_col[$this_col], $thislength );
            }
        }
    }

    my @lines;

    foreach my $record_r ( @{$self} ) {
        my @fields = @{$record_r};

        for my $this_col ( 0 .. $#fields - 1 ) {
            $fields[$this_col] = sprintf( '%-*s',
                $length_of_col[$this_col],
                ( $fields[$this_col] // q[] ) );
        }
        push @lines, join( $separator, @fields );

    }

    return \@lines;

} ## tidy end: sub tabulate

sub tabulated {
    my ( $class, $self ) = &$invocant_cr;
    my $lines_r = $class->tabulate( $self, @_ );
    return join( "\n", @$lines_r ) . "\n";
}

my $charcarp = sub {
    my $character  = shift;
    my $methodname = shift;
    carp "$character character found in array during $methodname; "
      . 'converted to visible symbol';
    return;
};

# I didn't put that inside the tsv method because I thought maybe someday
# there might be ->csv or something else.

sub flattened {
    my ( $class, $self ) = &$invocant_cr;
    my @flattened = map { @{$_} } @$self;
    return @flattened;
}

sub tsv {

    # tab-separated-values,
    # suitable for something like File::Slurper::write_text

    # converts line feeds, tabs, and carriage returns to the Unicode
    # visible symbols for these characters. Which is probably wrong, but
    # why would you feed those in then...

    my ( $class, $orig ) = &$invocant_cr;
    my $self = $class->define($orig);

    my @headers = @_;
    if ( @headers == 1 and is_plain_arrayref( $headers[0] ) ) {
        @headers = @{ $headers[0] };
    }

    my @lines;
    push @lines, join( "\t", @headers ) if @headers;
    foreach my $row ( @{$self} ) {
        my @rowcopy = @{$row};
        foreach (@rowcopy) {
            $_ //= q[];
            if (s/\t/\x{2409}/g) {    # visible symbol for tab
                $charcarp->( "Tab", "$class->tsv" );
            }

        }
        push @lines, join( "\t", @rowcopy );
    }

    foreach (@lines) {
        if (s/\n/\x{240A}/g) {        # visible symbol for line feed
            $charcarp->( "Line feed", "$class->tsv" );
        }
        if (s/\r/\x{240D}/g) {        # visible symbol for carriage return
            $charcarp->( "Carriage return", "$class->tsv" );
        }
    }

    my $str = join( "\n", @lines ) . "\n";

    return $str;

} ## tidy end: sub tsv

sub file {
    my ( $class, $self ) = &$invocant_cr;

    my %params = validate(
        @_,
        {   headers     => { type => ARRAYREF, optional => 1 },
            output_file => 1,
            type        => 0,
        }
    );
    my $output_file = $params{output_file};
    my $type = $params{type} || $filetype_from_ext_r->($output_file);

    croak "Cannot determine type of $output_file in " . __PACKAGE__ . '->file'
      unless $type;

    if ( $type eq 'xlsx' ) {
        $class->xlsx( $self, \%params );
        return;
    }
    if ( $type eq 'tsv' ) {
        my $text = $class->tsv($self);

        if ( $params{headers} ) {
            $text = join( "\t", @{ $params{headers} } ) . "\n" . $text;
        }

        require File::Slurper;
        File::Slurper::write_text( $output_file, $text );
        return;
    }
    croak "Unrecognized type $type in " . __PACKAGE__ . '->file';
} ## tidy end: sub file

sub xlsx {
    my ( $class, $self ) = &$invocant_cr;
    my %params = validate(
        @_,
        {   headers     => { type => ARRAYREF, optional => 1 },
            format      => { type => HASHREF,  optional => 1 },
            output_file => 1,
        }
    );

    my $output_file       = $params{output_file};
    my $format_properties = $params{format};
    my @headers;
    if ( $params{headers} ) {
        @headers = @{ $params{headers} };
    }

    require Excel::Writer::XLSX;    ### DEP ###

    my $workbook = Excel::Writer::XLSX->new($output_file);
    croak "Can't open $output_file for writing: $!"
      unless defined $workbook;
    my $sheet = $workbook->add_worksheet();
    my @format;

    if ( defined $format_properties ) {
        push @format, $workbook->add_format(%$format_properties);
    }

    # an array @format is used because if it were a scalar, it would be undef,
    # where what we want if it is empty is no value at all

    my $unblessed = blessed $self ? $self->unblessed : $self;

    # Excel::Writer::XLSX checks 'ref' and not 'reftype'

    if (@headers) {
        $sheet->write_row( 0, 0, \@headers, @format );
        $sheet->write_col( 1, 0, $unblessed, @format );
    }
    else {
        $sheet->write_col( 0, 0, $unblessed, @format );
    }

    return $workbook->close();

} ## tidy end: sub xlsx

### _TEXT_COLUMNS

1;

__END__

=encoding utf8

=head1 NAME

Array:2D - Methods for simple array-of-arrays data structures

=head1 VERSION

This documentation refers to version 0.001_001

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Array::2D is a module that adds useful methods to Perl's
standard array of arrays ("AoA") data structure, as described in 
L<Perl's perldsc documentation|perldsc>.  That is, an array that
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
construction like C<< $array2d->[0][1] >>  for accessing a single
element, or C<< @{$array2d} >> to get the list of rows, is perfectly
acceptable. This module exists because the reference-based 
implementation of multidimensional arrays in Perl makes it difficult to
access, for example, a single column, or a two-dimensional slice,
without writing lots of extra code.

Array::2D uses "row" for the first dimension, and "column" or
"col"  for the second dimension. This does mean that the order
of (row, column) is the opposite of the usual (x,y) algebraic order.

Because this object is just an array of arrays, most of the methods
referring  to rows are here mainly for completeness, and aren't really
more useful than the native Perl construction (e.g., C<<
$array2d->last_row() >> is just a slower way of doing C<< $#{$array2d}
>>.)

On the other hand, most of the methods referring to columns are useful,
since there's no simple way of doing that in Perl.  Notably, the column
methods are careful, when a row doesn't have an entry, to to fill out
the column with undefined values. In other words, if there are five 
rows in the object, a requested column will always return five values,
although some of them might be undefined.

=head1 METHODS

Some general notes:

=over 

=item *

In all cases where an array of arrays is specified (I<aoa_ref>), this
can be either an Array::2D object or an array of arrays data
structure that is not an object. 

=item *

Where rows are columns are removed from the object (as with any of the 
C<pop_*>, C<shift_*>, C<del_*> methods), time-consuming assemblage of
return values is ommitted in void context.

=item *

Some care is taken to ensure that rows are not autovivified.  Normally, if the 
highest row in an arrayref-of-arrayrefs is 2, and a program
attempts to read the value of $aoa->[3]->[$anything], Perl will create 
an empty third row.  This module avoids autovification from just reading data.

=back

=head2 CLASS METHODS

=over

=item B<new( I<row_ref, row_ref...>)>

=item B<new( I<aoa_ref> )>

Returns a new Array::2D object.  It accepts a list of array 
references as arguments, which become the rows of the object.

If it receives only one argument, and that argument is an array of
arrays -- that is, a reference to an unblessed array, and in turn
that array only contains references to unblessed arrays -- then the
arrayrefs contained in that structure are made into the rows of a new
Array::2D object.

If you want it to bless an existing arrayref-of-arrayrefs, use
C<bless()>.  If you don't want to reuse the existing arrayrefs as
the rows inside the object, use C<clone()>.

If you think it's possible that the detect-an-AoA-structure could
give a false positive (you want a new object that might have only one row,
where each entry in that row is an reference to an unblessed array),
use C<Array::2D->bless ( [ @your_rows ] )>.

=item B<bless(I<row_ref, row_ref...>)>

=item B<bless(I<aoa_ref>)>

Just like new(), except that if passed a single arrayref which contains
only other arrayrefs, it will bless the outer arrayref and return it. 
This saves the time and memory needed to copy the rows.

Note that this blesses the original array, so any other references to
this data structure will become a reference to the object, too.

=item B<empty>

Returns a new, empty Array::2D object.

=item B<new_across(I<chunksize, element, element, ...>)>

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

=item B<new_down(I<chunksize, element, element, ...>)>

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

=item B<new_to_term_width (...)>

A combination of I<new_down> and I<tabulate_equal_width>.  Takes three named
arguments:

=over

=item array => I<arrayref>

A one-dimensional list of scalars.

=item separator => I<separator>

A scalar to be passed to ->tabulate_equal_width(). The default is a single space.

=item width => I<width>

The width of the terminal. If not specified, defaults to 80.

=back

The method determines the number of columns required, creates an
Array::2D object of that number of columns using new_down, and
then returns first the object and then the results of ->tabulate_equal_width() on
that object.

=item B<<< new_from_tsv(I<tsv_string, tsv_string...>) >>>

Returns a new object from a string containing tab-delimited values. 
The string is first split into lines (delimited by carriage returns,
line feeds, a CR/LF pair, or other characters matching Perl's \R) and
then split into values by tabs.

If multiple strings are provided, they will be considered additional
lines. So, one can pass the contents of an entire TSV file, the series
of lines in the TSV file, or a combination of two.

=item B<<< new_from_xlsx(I<xlsx_filespec, sheet_requested>) >>>

Returns a new object from a worksheet in an Excel XLSX file, consisting
of the rows and columns of that sheet. The I<sheet_requested> parameter
is passed directly to the C<< ->worksheet >> method of 
C<Spreadsheet::ParseXLSX>, which accepts a name or an index. If nothing
is passed, it requests sheet 0 (the first sheet).

=item B<<< new_from_file(I<filespec>) >>>

Returns a new object from a file on disk. If the file has the extension
.xlsx, passes that file to C<new_from_xlsx>. If the file has the
extension .txt, .tab, or .tsv, slurps the file in memory and passes the
result to C<new_from_tsv>.

(Future versions might accept CSV files as well, and test the contents
of .txt files to see whether they are comma-delimited or
tab-delimited.)

=back

=head2 CLASS/OBJECT METHODS

All class/object methods can be called as an object method on a blessed
Array::2D object:

  $self->clone();

Or as a class method, if one supplies the array of arrays as the first
argument:

  Array::2D->clone($self);

In the latter case, the array of arrays need not be blessed.

=over

=item B<clone()>

Returns new object which has copies of the data in the 2D array object.
The 2D array will be different, but if any of the elements of the 2D
array are themselves references, they will refer to the same things as
in the original 2D array.

=item B<unblessed()>

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
C<unblessed>. Use C<clone_unblessed> instead.

=item B<clone_unblessed()>

Returns a new, unblessed, array of arrays containing copies of the data
in the 2D array object.

The array of arrays will be different, but if any of the elements of
the  2D array are themselves references, they will refer to the same
things as in the original 2D array.

=item B<is_empty()>

Returns a true value if the object is empty, false otherwise.

=item B<height()>

Returns the number of rows in the object.  

=item B<width()>

Returns the number of columns in the object. (The number of elements in
the longest row.)

=item B<last_row()>

Returns the index of the last row of the object.  If the object is
empty, returns -1.

=item B<last_col()>

Returns the index of the last column of the object. (The index of the
last element in the longest row.) If the object is
empty, returns -1.

=item B<element(I<row_idx, col_idx>)>

Returns the element in the given row and column. A slower way of
saying C<< $array2d->[I<row_idx>][I<col_idx>] >>, except that it avoids
autovivification.  Like that construct, it will return undef if the element
does not already exist.

=item B<row(I<row_idx>)>

Returns the elements in the given row.  A slower way of saying  C<<
@{$array2d->[I<row_idx>]} >>, except that it avoids autovivification.

=item B<col(I<col_idx>)>

Returns the elements in the given column.

=item B<< rows(I<row_idx, row_idx...>) >>

Returns a new Array::2D object with all the columns of the 
specified rows.

=item B<cols(I<col_idx>, <col_idx>...)>

Returns a new Array::2D object with all the rows of the specified columns.

=item B<slice(I<firstcol_idx, lastcol_idx, firstrow_idx, lastrow_idx>)>

Takes a two-dimensional slice of the object; like cutting a rectangle
out of the object.

In void context, alters the original object, which then will contain
only the area specified; otherwise, creates a new Array::2D 
object and returns the object.

=item B<set_element(I<row_idx, col_idx, value>)>

Sets the element in the given row and column to the given value. 
Just a slower way of saying 
C<< $array2d->[I<row_idx>][I<col_idx>] = I<value> >>.

=item B<set_row(I<row_idx , value, value...>)>

Sets the given row to the given set of values.
A slower way of saying  C<< {$array2d->[I<row_idx>] = [ @values ] >>.

=item B<set_col(I<col_idx, value, value...>)>

Sets the given column to the given set of values.  If more values are given than
there are rows, will add rows; if fewer values than there are rows, will set the 
entries in the remaining rows to C<undef>.

=item B<< set_rows(I<start_row_idx, array_of_arrays>) >>

=item B<< set_rows(I<start_row_idx, row_ref, row_ref ...>) >>

Sets the rows starting at the given start row index to the rows given.
So, for example, $obj->set_rows(1, $row_ref_a, $row_ref_b) will set 
row 1 of the object to be the elements of $row_ref_a and row 2 to be the 
elements of $row_ref_b.

The arguments after I<start_row_idx> are passed to C<new()>, so it accepts
any of the arguments that C<new()> accepts.

=item B<set_cols(I<start_col_idx, col_ref, col_ref>...)>

Sets the columns starting at the given start column index to the columns given.
So, for example, $obj->set_cols(1, $col_ref_a, $col_ref_b) will set 
column 1 of the object to be the elemnents of $col_ref_a and column 2 to be the
elements of $col_ref_b.

=item B<set_slice(I<first_row, first_col, array_of_arrays>)>

=item B<set_slice(I<first_row, first_col, row_ref, row_ref...>)>

Sets a rectangular segment of the object to have the values of the supplied
rows or array of arrays, beginning at the supplied first row and first column.
The arguments after the row and columns are passed to C<new()>, so it accepts
any of the arguments that C<new()> accepts.

=item B<shift_row()>

Removes the first row of the object and returns a list  of the elements
of that row.

=item B<shift_col()>

Removes the first column of the object and returns a list of the
elements of that column.

=item B<pop_row()>

Removes the last row of the object and returns a list of the elements
of that row.

=item B<pop_col()>

Removes the last column of the object and returns  a list of the
elements of that column.

=item B<push_row(I<element, element...>)>

Adds the specified elements as the new final row. Returns the new 
number of rows.

=item B<push_col(I<element, element...>)>

Adds the specified elements as the new final column. Returns the new 
number of columns.

=item B<push_rows(I<aoa_ref>)>

=item B<push_rows(I<row_ref, row_ref...>)>

Takes the specified array of arrays and adds them as new rows after the
end of the existing rows. Returns the new number of rows.

The arguments are passed to C<new()>, so it accepts
any of the arguments that C<new()> accepts.

=item B<push_cols(I<col_ref, col_ref...>)>

Takes the specified array of arrays and adds them as new columns, after
the end of the existing columns. Returns the new number of columns.

=item B<unshift_row(I<element, element...>)>

Adds the specified elements as the new first row. Returns the new 
number of rows.

=item B<unshift_col(I<element, element...>)>

Adds the specified elements as the new first column. Returns the new 
number of columns.

=item B<unshift_rows(I<aoa_ref>)>

=item B<unshift_rows(I<row_ref, row_ref...>)>

Takes the specified array of arrays and adds them as new rows before
the beginning of the existing rows. Returns the new number of rows.

The arguments are passed to C<new()>, so it accepts
any of the arguments that C<new()> accepts.

=item B<unshift_cols(I<col_ref, col_ref...>)>

Takes the specified array of arrays and adds them as new columns,
before the beginning of the existing columns. Returns the new number of
columns.

=item B<ins_row(I<row_idx, element, element...>)>

Adds the specified elements as a new row at the given index. Returns
the new number of rows.

=item B<ins_col(I<col_idx, element, element...>)>

Adds the specified elements as a new column at the given index. Returns
the new number of columns.

=item B<ins_rows(I<row_idx, aoa_ref>)>

Takes the specified array of arrays and inserts them as new rows at the
given index.  Returns the new number of rows.

The arguments after the row index are passed to C<new()>, so it accepts
any of the arguments that C<new()> accepts.

=item B<ins_cols(I<col_idx, col_ref, col_ref...>)>

Takes the specified array of arrays and inserts them as new columns at
the given index.  Returns the new number of columns.

=item B<del_row(I<row_idx>)>

Removes the row of the object specified by the index and returns a list
of the elements of that row.

=item B<del_col(I<col_idx>)>

Removes the column of the object specified by the index and returns a
list of the elements of that column.

=item B<del_rows(I<row_idx>, I<row_idx>...)>

Removes the rows of the object specified by the indices. Returns an
Array::2D object of those rows.

=item B<del_cols(I<col_idx>, I<col_idx>...)>

Removes the columns of the object specified by the indices. Returns an
Array::2D object of those columns.



=item B<transpose()>

Transposes the object: the elements that used to be in rows are now in
columns, and vice versa.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

=item B<prune()>

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

The C<prune> method eliminates these entirely undefined or empty
columns and rows at the end of the object.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

=item B<prune_empty()>

Like C<prune>, but treats not only undefined values as blank, but also 
empty strings.

=item B<prune_space()>

Like C<prune>, but treats not only undefined values as blank, but also 
strings that are empty or that consist solely of white space.

=item B<prune_callback(I<code_ref>)>

Like C<prune>, but calls the <code_ref> for each element, setting $_ to
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

=item B<apply(I<coderef>)>

Calls the C<$code_ref> for each element, aliasing $_ to each element in
turn. This allows an operation to be performed on every element.

For example, this would lowercase every element in the array (assuming
all values are defined):

 $obj->apply(sub {lc});

If an entry in the array is undefined, it will still be passed to the
callback.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

For each invocation of the callback, @_ is set to the row and column
indexes (0-based).

=item B<trim()>

Removes white space, if present, from the beginning and end  of each
element in the array.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

=item B<trim_right()>

Removes white space from the end of each element in the array.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

=item B<define()>

Replaces undefined values with the empty string.

In void context, alters the original object. Otherwise, creates a new
Array::2D object and returns the object.

=item B<hash_of_rows(I<col_idx>)>

Creates a hash reference.  The keys are the values in the specified
column of the array. The values are arrayrefs containing the elements
of the rows of the array, with the value in the key column removed.

If the key column is not specified, the first column is used for the
keys.

So:

 $obj = Array::2D->new([qw/a 1 2/],[qw/b 3 4/]);
 $hashref = $obj->hash_of_rows(0);
 # $hashref = { a => [ '1' , '2' ]  , b => [ '3' , '4' ] }

=item B<hash_of_row_elements(I<key_column_idx, value_column_idx>)>

Like C<hash_of_rows>, but accepts a key column and a value column, and
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

=item B<tabulate(I<separator>)>

Returns an arrayref of strings, where each string consists of the
elements of each row, padded with enough spaces to ensure that each
column has a consistent width.

The columns will be separated by whatever string is passed to
C<tabulate()>.  If nothing is passed, a single space will be used.

So, for example,

 $obj = Array::2D->new([qw/a bbb cc/],[qw/dddd e f/]);
 $arrayref = $obj->tabulate();

 # $arrayref = [ 'a    bbb cc' ,
                 'dddd e   f'] ;

If the C<Unicode::GCString|Unicode::GCString> module can be loaded,
its C<columns> method will be used to determine the width of each
character. This will treat composed accented characters and
double-width Asian characters correctly.

=item B<tabulated(I<separator>)>

Like C<tabulate()>, but returns the data as a single string, using
line feeds as separators of rows, suitable for sending to a terminal.

=item B<tabulate_equal_width(I<separator>)>

Like C<tabulate()>, but instead of each column having its own width,
all columns have the same width.

=item B<< tsv(I<headers>) >>

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

=item B<< xlsx(...) >>

Accepts a file specification and creates a new Excel XLSX file at that 
location, with one sheet, containing the data in the 2D array.

This method uses named parameters.

=over

=item output_file

This mandatory parameter contains the file specification.

=item headers

This parameter is optional. If present, it contains an array reference
to be used as the first row in the Excel file.

The idea is that these will be the headers of the columns. It's not
really any different than putting the column headers as the first
element of the data, but frequently these are stored separately. At
this point no attempt is made to make them bold or anything like that.

=item format

This parameter is optional. If present, it contains a hash reference,
with format parameters as specified by Excel::Writer::XLSX.

=back

=item B<<file(...) >>

Accepts a file specification and creates a new file at that  location
containing the data in the 2D array.

This method uses named parameters.

=over

=item type

This parameter is the file's type. Currently, the types recognized are
'tsv' for tab-separated values, and 'xlsx' for Excel XLSX. If the type
is not given, it attempts to determine the type from the file
extension, which can be (case-insensitively) 'xlsx' for Excel XLSX
files  or 'tab', 'tsv' or 'txt' for  tab-separated value files.

=item output_file

This mandatory parameter contains the file specification.

=item headers

This parameter is optional. If present, it contains an array reference
to be used as the first row in the ouptut file.

The idea is that these will be the headers of the columns. It's not
really any different than putting the column headers as the first
element of the data, but frequently these are stored separately.

=item type

=back

=back

=head1 DIAGNOSTICS

=head2 ERRORS

=over

=item Arguments to Array::2D->new or Array::2D->blessed must be unblessed arrayrefs (rows)

A non-arrayref, or blessed object (other than an Array::2D object), was 
passed to the new constructor.

=item Sheet $sheet_requested not found in $xlsx in Array::2D->new_from_xlsx

Spreadsheet::ParseExcel returned an error indicating that the sheet
requested was not found.

=item File type unrecognized in $filename passed to Array::2D->new_from_file

A file other than an Excel (XLSX) or tab-delimited text files (with
tab,  tsv, or txt extensions) are recognized in ->new_from_file.

=item No file specified in Array::2D->new_from_file

=item No file specified in Array::2D->new_from_xlsx

No filename, or a blank filename, was passed to these methods.

=back

=head2 WARNINGS

=over

=item Tab character found in array during Array::2D->tsv; converted to visible symbol

=item Line feed character found in array during Array::2D->tsv; converted to visible symbol

=item Carriage return character found in array during Array::2D->tsv; converted to visible symbol

An invalid character for TSV data was found in the array when creating 
TSV data. It was converted to the Unicode visible symbol for that
character, but this warning was issued.

=back

=head1 TO DO

=over

=item *

Add CSV (and possibly other file type) support to new_from_file.

=back

=head1 DEPENDENCIES

=over

=item Perl 5.8.1 or higher

=item List::MoreUtils

=item Params::Validate

=item File::Slurper

=item Spreadsheet::ParseXLSX

=item Excel::Writer::XLSX

The last three are required only by those methods that use them 
(C<new_from_tsv>, C<new_from_xlsx>, and C<xlsx> respectively).

=back

=head1 AUTHOR

Aaron Priven <apriven@actransit.org>

=head1 COPYRIGHT & LICENSE

Copyright 2015, 2017

This program is free software; you can redistribute it and/or modify it
under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

=item * the Artistic License version 2.0.

=back

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
