=encoding utf-8

=head1 NAME

parser.t - Unittests for ABAPMonk::Parser

=cut

use strict;
use warnings;
use utf8;

use Test::More;
use Data::Dumper;

plan tests => 7;

use ABAPMonk::Parser;
use ABAPMonk::Statements::Data;
use ABAPMonk::Statements::FieldSymbol;
use ABAPMonk::Statements::Constant;
use ABAPMonk::Statements::CommentBlock;
use ABAPMonk::Statements::Form;
use ABAPMonk::Statements::Argument;

my $parser = ABAPMonk::Parser->new;
my $text = "";
my @result = ( 0 );
my @result_exp = ( 1 );

################################################################################
# Test no source code
$text = '';

@result = $parser->parse($text);
@result_exp = ( );

ok eq_array(\@result, \@result_exp), "Parsing no source code failed";

################################################################################
# Test DATA
$text = "* This is a test" . "\n";
$text .= "* testing some data declarations" . "\n";
$text .= "DATA: lf_i TYPE int4. DATA: lf_test011 TYPE string." . "\n";
$text .= "* Fields to eliminate duplicates:" . "\n";
$text .= "DATA: lt_duplicates TYPE TABLE OF matnr." . "\n";
$text .= "DATA: lt_matnr TYPE /test/tt_matnr." . "\n";
$text .= "DATA: lrt_werks TYPE RANGE OF werks_d." . "\n";
$text .= "DATA: lcl_data TYPE REF TO data." . "\n";

@result_exp = ( ABAPMonk::Statements::CommentBlock->new(["This is a test",
                                                    "testing some data declarations"]),
                ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string"),
                ABAPMonk::Statements::CommentBlock->new(["Fields to eliminate duplicates:"]),
                ABAPMonk::Statements::Data->new("lt_duplicates", "TYPE TABLE OF", "matnr"),
                ABAPMonk::Statements::Data->new("lt_matnr", "TYPE", "/test/tt_matnr" ),
                ABAPMonk::Statements::Data->new("lrt_werks", "TYPE RANGE OF", "werks_d" ),
                ABAPMonk::Statements::Data->new("lcl_data", "TYPE REF TO", "data" ) );
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing DATA failed";

################################################################################
# Test FIELD-SYMBOL
$text = "FIELD-SYMBOLS: <lf_i> TYPE int4. FIELD-SYMBOLS: <lf_test011> TYPE string." . "\n";

@result_exp = ( ABAPMonk::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                ABAPMonk::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string") );
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing FIELD-SYMBOL failed";

################################################################################
# Test CONSTANT
$text = "CONSTANTS: c_i TYPE int4 VALUE 9999-. CONSTANTS: c_str TYPE string VALUE 'Hello world!'." . "\n";
$text .= "CONSTANTS: c_duplicate TYPE matnr VALUE 'DUPLICATE'." . "\n";
$text .= "CONSTANTS: c_j TYPE float
                         VALUE 1234." . "\n";

@result_exp = ( ABAPMonk::Statements::Constant->new("c_i", "TYPE", "int4", "9999-"),
                ABAPMonk::Statements::Constant->new("c_str", "TYPE", "string", "'Hello world!'"),
                ABAPMonk::Statements::Constant->new("c_duplicate", "TYPE", "matnr", "'DUPLICATE'"),
                ABAPMonk::Statements::Constant->new("c_j", "TYPE", "float", "1234"));
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing CONSTANT failed";



################################################################################
# Test CONSTANT + DATA + FIELD-SYMBOL
$text = "CONSTANTS: c_i TYPE int4 VALUE 9999-. CONSTANTS: c_str TYPE string VALUE 'Hello world!'." . "\n";
$text .= "DATA: lf_i TYPE int4. DATA: lf_test011 TYPE string." . "\n";
$text .= "FIELD-SYMBOLS: <lf_i> TYPE int4. FIELD-SYMBOLS: <lf_test011> TYPE string." . "\n";
$text .= "DATA: lf_very_long_field TYPE string." . "\n";
$text .= "DATA: lt_matnr TYPE TABLE OF matnr." . "\n";
$text .= "FIELD-SYMBOLS: <lf_matnr> LIKE LINE OF lt_matnr." . "\n";

@result_exp = ( ABAPMonk::Statements::Constant->new("c_i", "TYPE", "int4", "9999-"),
                ABAPMonk::Statements::Constant->new("c_str", "TYPE", "string", "'Hello world!'"),
                ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string"),

                ABAPMonk::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                ABAPMonk::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),

                ABAPMonk::Statements::Data->new("lf_very_long_field", "TYPE", "string"),
                ABAPMonk::Statements::Data->new("lt_matnr", "TYPE TABLE OF", "matnr"),

                ABAPMonk::Statements::FieldSymbol->new("<lf_matnr>", "LIKE LINE OF", "lt_matnr") );
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing DATA + FIELD-SYMBOL failed";

################################################################################
# Test simple FORM
$text = 'FORM test.
DATA: lf_i TYPE int4.
DATA: lf_test011 TYPE string.
ENDFORM.';

{
    my @using = ( );
    my @changing = ( );
    my @tables = ( );
    my @statements = ( ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                       ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string") );
    @result_exp = ( ABAPMonk::Statements::Form->new("test",
                                               \@using,
                                               \@changing,
                                               \@tables,
                                               \@statements) );
}
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing simple FORM failed";

################################################################################
# Test FORM with USING and CHANGING
$text = 'FORM test USING i_a TYPE int4
i_b TYPE int4
i_comparator TYPE string
CHANGING e_result TYPE int4.
DATA: lf_i TYPE int4.
DATA: lf_test011 TYPE string.
ENDFORM.';

{
    my @using = ( ABAPMonk::Statements::Argument->new("i_a", "TYPE", "int4"),
                  ABAPMonk::Statements::Argument->new("i_a", "TYPE", "int4"),
                  ABAPMonk::Statements::Argument->new("i_comparator", "TYPE", "string") );
    my @changing = ( ABAPMonk::Statements::Argument->new("e_result", "TYPE", "int4") );
    my @tables = ( );
    my @statements = ( ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                       ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string") );
    @result_exp = ( ABAPMonk::Statements::Form->new("test",
                                               \@using,
                                               \@changing,
                                               \@tables,
                                               \@statements) );
}
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing FORM with USING and CHANGING failed";
