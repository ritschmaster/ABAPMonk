package SAF::Formatter;

sub new {
    my ($class) = @_;

    my $self = { };

    bless $self, $class;

    return $self;
}

# Formats SAF::Statement::Data and SAF::Statement::FieldSymbol objects.
#
# $i is the index at which a SAF::Statement::Data or SAF::Statement::FieldSymbol object was found
#
# Returns the formatted string and the new index position.
sub _format_data {
    my ($self, $statements_ref, $i) = @_;
    my @statements = @{$statements_ref};

    my $len_to_type_decl = 0;
    my $statement = $statements[$i];
    my @data_statements = ($statement);
    for ($j = $i; (ref($statement) eq "SAF::Statements::Data"
                   || ref($statement) eq "SAF::Statements::FieldSymbol")
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

        if (ref($statement) eq "SAF::Statements::Data"
            || ref($statement) eq "SAF::Statements::FieldSymbol") {
            # Search for the next few statements
            my $formatted_data = "";

            ($formatted_data, $i) = $self->_format_data(\@statements, $i);
            $formatted .= $formatted_data;
        }

        $formatted .= "\n" if $i + 1 < $statements_len;
    }

    return $formatted;
}

1;
