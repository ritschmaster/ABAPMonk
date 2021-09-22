package Statement;

use strict;
use warnings;

use constant STATEMENT_END_STR => ".";

sub new {
    my $self = { };

    bless $self;

    return $self;
}

sub _simple_format {
    my ($self) = @_;

    return '';
}

sub _complex_format {
    my ($self, $arg) = @_;

    return '';
}

# If $arg is not supplied, then the statement is formatted just using single blanks.
sub format {
    my ($self, $arg) = @_;

    my $formatted = '';
    if (@_ == 1) {
        $formatted = $self->_simple_format();
    } else {
        $formatted = $self->_complex_format($arg);
    }

    return $formatted;
}

1;
