=encoding utf-8

=head1 NAME

ABAPMonk::Parser - Parse a given plain text

=cut

package ABAPMonk::Parser;

use strict;
use warnings;

use Regexp::Grammars;

use ABAPMonk::Statements::Data;
use ABAPMonk::Statements::FieldSymbol;
use ABAPMonk::Statements::Constant;
use ABAPMonk::Statements::CommentBlock;
use ABAPMonk::Statements::Form;
use ABAPMonk::Statements::Argument;

=head1 APPEDIX

=head2 new

Signature: new()

There are no parameters.

Returns a new ABAPMonk::Parser object.

=cut
sub new {
        my ($class) = @_;

        my $parser = qr{
        <SourceCode>

        <rule: SourceCode>        <[GlobalDeclaration]>*

        <rule: GlobalDeclaration> <[DataDeclaration]>+
                                  | <[CommentBlock]>+
                                  | <[Form]>+

        <rule: DataDeclaration>   <Data>
                                  | <FieldSymbol>
                                  | <Constant>

        <rule: Statement>         <DataDeclaration>
                                  | <If>

        <rule: CommentBlock>      <[CommentLine]>+

        <rule: CommentLine>       \*.*

        <rule: Comment>           ".*


        <rule: Data>              # DATA:
                                  [dD][aA][tT][aA]: <Field> <TypeDecl> <Type> <StatementEnd>

        <rule: FieldSymbol>       # FIELD-SYMBOLS:
                                  [fF][iI][eE][lL][dD]-[sS][yY][mM][bB][oO][lL][sS]: <FieldSymbolField> <TypeDecl> <Type> <StatementEnd>

        <rule: Constant>          # CONSTANTS:
                                  [cC][oO][nN][sS][tT][aA][nN][tT][sS]: <Field> <TypeDecl> <Type> VALUE <Value> <StatementEnd>

        <rule: Field>             [a-zA-Z0-9_-]+

        <rule: FieldSymbolField>  \<[a-zA-Z0-9_-]+\>

        <rule: TypeDecl>
                                  # TYPE
                                  [tT][yY][pP][eE]
                                  # TYPE LINE OF
                                  | [tT][yY][pP][eE] [lL][iI][nN][eE] [oO][fF]

                                  # TYPE TABLE OF
                                  | [tT][yY][pP][eE] [tT][aA][bB][lL][eE] [oO][fF]

                                  # TYPE STANDARD TABLE OF
                                  | [tT][yY][pP][eE] [sT][aA][nN][dD][aA][rR][dD] [tT][aA][bB][lL][eE] [oO][fF]

                                  # TYPE RANGE OF
                                  | [tT][yY][pP][eE] [rR][aA][nN][gG][eE] [oO][fF]

                                  # TYPE REF TO
                                  | [tT][yY][pP][eE] [rR][eE][fF] [tT][oO]

                                  # LIKE
                                  | [lL][iI][kK][eE]

                                  # LIKE LINE OF
                                  | [lL][iI][kK][eE] [lL][iI][nN][eE] [oO][fF]

                                  # LIKE TABLE OF
                                  | [lL][iI][kK][eE] [tT][aA][bB][lL][eE] [oO][fF]

                                  # LIKE STANDARD TABLE OF
                                  | [lL][iI][kK][eE] [sT][aA][nN][dD][aA][rR][dD] [tT][aA][bB][lL][eE] [oO][fF]

                                  # LIKE RANGE OF
                                  | [lL][iI][kK][eE] [rR][aA][nN][gG][eE] [oO][fF]

        <rule: Type>              ([/a-zA-Z0-9_-]|=>)+

        <rule: Value>             '.*' | [0-9]+[-]{0,1}

        <rule: StatementEnd>      \.

        <rule: Form>             # FORM
                                 [fF][oO][rR][mM] <FormName> <StatementEnd>
                                   <[Statement]>*
                                 # ENDFORM
                                 [eE][nN][dD][fF][oO][rR][mM] <StatementEnd>

                                 # FORM
                                 | [fF][oO][rR][mM] <FormName> <Using> <StatementEnd>
                                     <[Statement]>*
                                 # ENDFORM
                                 [eE][nN][dD][fF][oO][rR][mM] <StatementEnd>

                                 # FORM
                                 | [fF][oO][rR][mM] <FormName> <Using> <Changing> <StatementEnd>
                                     <[Statement]>*
                                 # ENDFORM
                                 [eE][nN][dD][fF][oO][rR][mM] <StatementEnd>

        <rule: FormName>         [a-zA-Z0-9_-]+

        <rule: Using>            # USING
                                 [uU][sS][iI][nN][gG] <[Argument]>+

        <rule: Changing>         # CHANGING
                                 [cC][hH][aA][nN][gG][iI][nN][gG] <[Argument]>+

        <rule: Argument>         <Field> <TypeDecl> <Type>

        <rule: If>               # IF
                                 [iI][fF] <[Condition]> <StatementEnd>
                                   <[Statement]>*
                                 <[ElseIf]>*
                                 # ENDIF
                                 [eE][nN][dD][iI][fF] <StatementEnd>

        <rule: Condition>        <Field> = <Field>

        <rule: ElseIf>           # ELSEIF
                                 [eE][lL][sS][eE][iI][fF] <[Condition]>+ <StatementEnd>
        };


        my $self = { _parser => $parser };

        bless $self, $class;;

        return $self;
}

=head2 _parse_data_declration

Signature: _parse_data_declration($data_declaration)

The parameter $data_declaration is a deep hash.

=cut
sub _parse_data_declaration {
        my ($self, $data_declaration) = @_;

        my $parsed_statement = 0;
        my $data = ${ $data_declaration }{ Data };
        my $field_symbol = ${ $data_declaration }{ FieldSymbol };
        my $constant = ${ $data_declaration }{ Constant };
        if ($data) {
                $parsed_statement = ABAPMonk::Statements::Data->new(${ $data }{ Field },
                                                               ${ $data }{ TypeDecl },
                                                               ${ $data }{ Type });
        } elsif ($field_symbol) {
                $parsed_statement = ABAPMonk::Statements::FieldSymbol->new(${ $field_symbol }{ FieldSymbolField },
                                                                      ${ $field_symbol }{ TypeDecl },
                                                                      ${ $field_symbol }{ Type });
        } elsif ($constant) {
                $parsed_statement = ABAPMonk::Statements::Constant->new(${ $constant }{ Field },
                                                                   ${ $constant }{ TypeDecl },
                                                                   ${ $constant }{ Type },
                                                                   ${ $constant }{ Value });
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

sub _parse_comment_block {
    my ($self, $comment_block_ref) = @_;

    my @text_lines = ( );
    foreach my $comment_block_line ( @{ $comment_block_ref } ) {
            my @comment_lines = @{ ${ $comment_block_line }{ CommentLine } };
            #@comment_lines = $comment_lines[0];
            foreach my $comment_line ( @comment_lines ) {
                    my $text_line = $comment_line;
                    $text_line =~ s/^[\n]*\*\s+//; # Remove leading * with leading space
                    push @text_lines, $text_line;
            }
    }

    return ABAPMonk::Statements::CommentBlock->new(\@text_lines);
}

sub _parse_argument {
        my ($self, $argument) = @_;

        my $parsed_statement = 0;
        if ($argument) {
                $parsed_statement = ABAPMonk::Statements::Argument->new(${ $argument }{ Field },
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

=head2 _parse_form

The parameter $form is a deep hash.

=cut
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

        my $parsed_statement = ABAPMonk::Statements::Form->new($name,
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
                my $comment_block_ref = ${ $global_declaration }{ CommentBlock };
                my $forms_ref  = ${ $global_declaration }{ Form };

                if (defined $data_declarations_ref) {
                        my @data_declarations = @{ $data_declarations_ref };
                        push @parsed_statements, $self->_parse_data_declarations(\@data_declarations);
                } elsif (defined $comment_block_ref) {
                        my @comment_block = @{ $comment_block_ref };
                        push @parsed_statements, $self->_parse_comment_block(\@comment_block);
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
        #                my $parsed_data = ABAPMonk::Statements::Data->new(${ $data }{ Field },
        #                                                             ${ $data }{ TypeDecl },
        #                                                             ${ $data }{ Type });
        #                push @parsed_statements, $parsed_data;
        #        } elsif (${ $statement }{ FieldSymbol }) {
        #                my $field_symbol= ${ $statement }{ FieldSymbol };
        #                my $parsed_field_symbol = ABAPMonk::Statements::FieldSymbol->new(${ $field_symbol }{ FieldSymbolField },
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

        #                my $parsed_form = ABAPMonk::Statements::Form->new(  );
        #        } else {
        #                # TODO
        #        }
        #}

        return @parsed_statements;
}

=head2 parse

Signature: parse($text)

The parameter $text is a string containing ABAP code to parse.

=cut
sub parse {
        my ($self, $text) = @_;

        $text =~ $self->{ _parser };
        my %simple_parse_tree = %/;

        my @statements = $self->_parse(\%simple_parse_tree);

        return @statements;
}

1;
