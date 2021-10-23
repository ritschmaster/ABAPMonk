=encoding utf-8

=head1 NAME

ABAPMonk::Formatter - Format ABAPMonk ABAP objects to plain text

=cut

package ABAPMonk::Formatter;

sub new {
    my ($class) = @_;

    my $self = { };

    bless $self, $class;

    return $self;
}

=head2 _format_data

Formats ABAPMonk::Statement::Data and ABAPMonk::Statement::FieldSymbol objects.

Signature: _format_data($statements_ref, $i)

The parameter $i is the index at which a ABAPMonk::Statement::Data or ABAPMonk::Statement::FieldSymbol object was found.

Returns the formatted string and the new index position.

=cut
sub _format_data {
    my ($self, $statements_ref, $i) = @_;
    my @statements = @{$statements_ref};

    my $len_to_type_decl = 0;
    my $statement = $statements[$i];
    my @data_statements = ($statement);
    for ($j = $i; (ref($statements[$j]) eq "ABAPMonk::Statements::Data"
                   || ref($statements[$j]) eq "ABAPMonk::Statements::FieldSymbol")
                   && $j < scalar @statements; $j++) {
        $statement = $statements[$j];
        my $new_len_to_type_decl = $statement->len_to_type_decl;
        $len_to_type_decl = $new_len_to_type_decl if $new_len_to_type_decl > $len_to_type_decl;
    }
    $j--;

    my $formatted = "";
    for ($k = $i; $k <= $j; $k++) {
        $statement = $statements[$k];
        $formatted .= $statement->format($len_to_type_decl);
        if ($k + 1 <= $j) {
            $formatted .= "\n";
            $formatted .= "\n" if ref($statement) ne ref($statements[$k + 1]);
        }
    }

    return ($formatted, $j);
}

sub format {
    my ($self, @statements) = @_;

    my $formatted = "";

    my $statements_len = scalar @statements;
    for (my $i = 0; $i < $statements_len; $i++) {
        my $statement = $statements[$i];

        if (ref($statement) eq "ABAPMonk::Statements::Data"
            || ref($statement) eq "ABAPMonk::Statements::FieldSymbol"
            || ref($statement) eq "ABAPMonk::Statements::Constant") {
            # Search for the next few statements
            my $formatted_data = "";

            ($formatted_data, $i) = $self->_format_data(\@statements, $i);
            $formatted .= $formatted_data;
        } elsif (ref($statement) eq "ABAPMonk::Statements::CommentBlock") {
            $formatted .= $statement->format();
        }

        $formatted .= "\n" if $i + 1 < $statements_len;
    }

    return $formatted;
}

1;
