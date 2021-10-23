=encoding utf-8

=head1 NAME

ABAPMonk::Statements::FieldSymbol - Parsed ABAP statement "FIELD-SYMBOL:"

=cut

package ABAPMonk::Statements::FieldSymbol;

use strict;
use warnings;

use ABAPMonk::Statement;

our @ISA = qw(Statement);

sub new {
    my ($class, $field, $type_decl, $type) = @_;

    my $self = $class->SUPER::new;

    $self->{ _field } = $field;
    $self->{ _type_decl } = $type_decl;
    $self->{ _type } = $type;

    bless $self, $class;

    return $self;
}

sub _prefix {
    my ($self) = @_;

    return "FIELD-SYMBOLS: " . $self->{ _field };
}

# Get the length to the type declaration
sub len_to_type_decl {
    my ($self) = @_;

    my $prefix = $self->_prefix;

    return length $prefix;
}

sub _simple_format {
    my ($self) = @_;

    my $formatted = "FIELD-SYMBOLS: " . $self->{ _field }
                    . " "
                    . $self->{ _type_decl } . " " . $self->{ _type } . $self->STATEMENT_END_STR;

    return $formatted;
}

sub _complex_format {
    my ($self, $len_to_type_decl) = @_;

    my $prefix= $self->_prefix;
    my $suffix = $self->{ _type_decl } . " " . $self->{ _type } . $self->STATEMENT_END_STR;

    my $prefix_len = length $prefix;

    my $blanks = '';
    for (my $i = $prefix_len - 2; $i < $len_to_type_decl; $i++) {
        $blanks .= ' ' if $i + 1 < $len_to_type_decl;
    }

    my $formatted = $prefix . $blanks . $suffix;

    return $formatted;
}

1;
