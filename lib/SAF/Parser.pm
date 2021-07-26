package SAF::Parser;

use strict;
use warnings;

use Regexp::Grammars;

use SAF::Statements::Data;
use SAF::Statements::FieldSymbol;
use SAF::Statements::Form;
use SAF::Statements::Argument;

sub new {
        my ($class) = @_;

        my $parser = qr{
        <SourceCode>

        <rule: SourceCode>        <[GlobalDeclaration]>*

        <rule: GlobalDeclaration> <[DataDeclaration]>+ | <[Form]>+

        <rule: DataDeclaration>   <Data> | <FieldSymbol>

        <rule: Statement>         <DataDeclaration>

        <rule: Data>              DATA: <Field> <TypeDecl> <Type> <StatementEnd>

        <rule: FieldSymbol>       FIELD-SYMBOL: <FieldSymbolField> <TypeDecl> <Type> <StatementEnd>

        <rule: Field>             [a-zA-Z0-9_-]+

        <rule: FieldSymbolField>  \<[a-zA-Z0-9_-]+\>

        <rule: TypeDecl>          TYPE

        <rule: Type>              [a-zA-Z0-9_-]+

        <rule: StatementEnd>      \.

        <rule: Form>             FORM <FormName> <StatementEnd>
                                   <[Statement]>*
                                 ENDFORM <StatementEnd>

                                 | FORM <FormName> <Using> <StatementEnd>
                                     <[Statement]>*
                                   ENDFORM <StatementEnd>

                                 | FORM <FormName> <Using> <Changing> <StatementEnd>
                                     <[Statement]>*
                                   ENDFORM <StatementEnd>


        <rule: FormName>         [a-zA-Z0-9_-]+

        <rule: Using>            USING <[Argument]>+

        <rule: Changing>         CHANGING <[Argument]>+

        <rule: Argument>         <Field> <TypeDecl> <Type>
        };


        my $self = { _parser => $parser };

        bless $self, $class;;

        return $self;
}

sub _parse_data_declaration {
        my ($self, $data_declaration) = @_;

        my $parsed_statement = 0;
        my $data = ${ $data_declaration }{ Data };
        my $field_symbol = ${ $data_declaration }{ FieldSymbol };
        if ($data) {
                $parsed_statement = SAF::Statements::Data->new(${ $data }{ Field },
                                                               ${ $data }{ TypeDecl },
                                                               ${ $data }{ Type });
        } elsif ($field_symbol) {
                $parsed_statement = SAF::Statements::FieldSymbol->new(${ $field_symbol }{ FieldSymbolField },
                                                                      ${ $field_symbol }{ TypeDecl },
                                                                      ${ $field_symbol }{ Type });
        } else {
                # TODO
        }

        return $parsed_statement;
}

sub _parse_data_declarations {
        my ($self, $data_declarations_ref) = @_;

        my @parsed_statements = ( );
        foreach my $data_declaration ( @{ $data_declarations_ref } ) {
                push @parsed_statements, $self->_parse_data_declaration($data_declaration);
        }

        return @parsed_statements;
}

sub _parse_argument {
        my ($self, $argument) = @_;

        my $parsed_statement = 0;
        if ($argument) {
                $parsed_statement = SAF::Statements::Argument->new(${ $argument }{ Field },
                                                                   ${ $argument }{ TypeDecl },
                                                                   ${ $argument }{ Type });
        } else {
                # TODO
        }

        return $parsed_statement;
}

sub _parse_arguments {
        my ($self, $arguments_ref) = @_;

        my @parsed_arguments = ( );
        foreach my $argument ( @{ $arguments_ref } ) {
                push @parsed_arguments, $self->_parse_argument($argument);
        }

        return @parsed_arguments;
}

sub _parse_form {
        my ($self, $form) = @_;

        my $name = ${ $form }{ FormName };

        my @usings = ( );
        @usings = @{ ${ ${ $form }{ Using } }{ Argument } } if (defined ${ $form }{ Using });
        my @parsed_using = $self->_parse_arguments(\@usings);

        my @changings = ( );
        @changings = @{ ${ ${ $form }{ Changing } }{ Argument } } if (defined ${ $form }{ Changing });
        my @parsed_changing = $self->_parse_arguments(\@changings);

        my @parsed_tables = ( );

        my @statements = @{ ${ $form }{ Statement } };
        my @parsed_statements = ( );
        foreach my $statement ( @statements ) {
                my $data_declaration = ${ $statement }{ DataDeclaration };

                if (defined $data_declaration) {
                        push @parsed_statements, $self->_parse_data_declaration($data_declaration);
                } else {
                        # TODO
                }
        }

        my $parsed_statement = SAF::Statements::Form->new($name,
                                                          \@parsed_using,
                                                          \@parsed_changing,
                                                          \@parsed_tables,
                                                          \@parsed_statements);

        return $parsed_statement;
}

sub _parse_forms {
        my ($self, $forms_ref) = @_;

        my @parsed_statements = ( );
        foreach my $form ( @{ $forms_ref } ) {
                push @parsed_statements, $self->_parse_form($form);
        }

        return @parsed_statements;
}

sub _parse {
        my ($self, $parse_tree_ref) = @_;

        my %parse_tree = %{ $parse_tree_ref };
        my @global_declarations = ( );
        if ($parse_tree{ SourceCode }) {
                my %source_tree = %{ $parse_tree{ SourceCode } };
                @global_declarations = @{ $source_tree{ GlobalDeclaration } };
        }

        my @parsed_statements = ( );

        foreach my $global_declaration ( @global_declarations ) {
                my $data_declarations_ref = ${ $global_declaration }{ DataDeclaration };
                my $forms_ref  = ${ $global_declaration }{ Form };

                if (defined $data_declarations_ref) {
                        my @data_declarations = @{ $data_declarations_ref };
                        push @parsed_statements, $self->_parse_data_declarations(\@data_declarations);
                } elsif (defined $forms_ref) {
                        my @forms = @{ $forms_ref };
                        push @parsed_statements, $self->_parse_forms(\@forms);
                } else {
                        # TODO
                }
        }

        #foreach my $statement ( @data_delcarations) {
        #        if (${ $statement }{ Data }) {
        #                my $data = ${ $statement }{ Data };
        #                my $parsed_data = SAF::Statements::Data->new(${ $data }{ Field },
        #                                                             ${ $data }{ TypeDecl },
        #                                                             ${ $data }{ Type });
        #                push @parsed_statements, $parsed_data;
        #        } elsif (${ $statement }{ FieldSymbol }) {
        #                my $field_symbol= ${ $statement }{ FieldSymbol };
        #                my $parsed_field_symbol = SAF::Statements::FieldSymbol->new(${ $field_symbol }{ FieldSymbolField },
        #                                                                            ${ $field_symbol }{ TypeDecl },
        #                                                                            ${ $field_symbol }{ Type });
        #                push @parsed_statements, $parsed_field_symbol;
        #        } else {
        #                # TODO
        #        }
        #}

        #foreach my $func_declaration ( @func_declarations ) {
        #        if (${ $statement }{ Form }) {
        #                my $form = ${ $statement }{ Form };

        #                foreach my $form_statement ()

        #                my $parsed_form = SAF::Statements::Form->new(  );
        #        } else {
        #                # TODO
        #        }
        #}

        return @parsed_statements;
}

sub parse {
        my ($self, $text) = @_;

        $text =~ $self->{ _parser };
        my %simple_parse_tree = %/;

        my @statements = $self->_parse(\%simple_parse_tree);

        return @statements;
}

1;
