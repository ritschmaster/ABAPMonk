package SAF::Parser;

use strict;
use warnings;

use Regexp::Grammars;

use SAF::Statements::Data;
use SAF::Statements::FieldSymbol;

sub new {
        my ($class) = @_;

        my $parser = qr{
        <SourceCode>

        <rule: SourceCode>        <[Statement]>*

        <rule: Statement>         <Data> | <FieldSymbol>

        <rule: Data>              DATA: <Field> <TypeDecl> <Type> <StatementEnd>

        <rule: FieldSymbol>       FIELD-SYMBOL: <FieldSymbolField> <TypeDecl> <Type> <StatementEnd>

        <rule: Field>             [a-zA-Z0-9_-]+

        <rule: FieldSymbolField>  \<[a-zA-Z0-9_-]+\>

        <rule: TypeDecl>          TYPE

        <rule: Type>              [a-zA-Z0-9_-]+

        <rule: StatementEnd>      \.
        };


        my $self = { _parser => $parser };

        bless $self, $class;;

        return $self;
}
use Test::More;

sub _parse {
        my ($self, %parse_tree) = @_;

        my %source_tree = %{ $parse_tree{ SourceCode } };
        my @statements = @{ $source_tree{ Statement } };

        my @parsed_statements = ( );
        foreach my $statement ( @statements) {
                if (${ $statement }{ Data }) {
                        my $data = ${ $statement }{ Data };
                        my $parsed_data = SAF::Statements::Data->new(${ $data }{ Field },
                                                                     ${ $data }{ TypeDecl },
                                                                     ${ $data }{ Type });
                        push @parsed_statements, $parsed_data;
                } elsif (${ $statement }{ FieldSymbol }) {
                        my $field_symbol= ${ $statement }{ FieldSymbol };
                        my $parsed_field_symbol = SAF::Statements::FieldSymbol->new(${ $field_symbol }{ FieldSymbolField },
                                                                                    ${ $field_symbol }{ TypeDecl },
                                                                                    ${ $field_symbol }{ Type });
                        push @parsed_statements, $parsed_field_symbol;

                } else {
                        # TODO
                }
        }

        return @parsed_statements;
}

sub parse {
        my ($self, $text) = @_;

        $text =~ $self->{ _parser };
        my %simple_parse_tree = %/;

        my @statements = $self->_parse(%simple_parse_tree);

        return @statements;
}

1;
