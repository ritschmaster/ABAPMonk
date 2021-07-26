use strict;
use warnings;

use Test::More;
use Data::Dumper;

plan tests => 6;

use SAF::Parser;
use SAF::Statements::Data;
use SAF::Statements::FieldSymbol;
use SAF::Statements::Form;
use SAF::Statements::Argument;

my $parser = SAF::Parser->new;
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
$text = "DATA: lf_i TYPE int4. DATA: lf_test011 TYPE string.";

@result_exp = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                SAF::Statements::Data->new("lf_test011", "TYPE", "string") );
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing DATA failed";

################################################################################
# Test FIELD-SYMBOL
$text = "FIELD-SYMBOL: <lf_i> TYPE int4. FIELD-SYMBOL: <lf_test011> TYPE string.";

@result_exp = ( SAF::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                SAF::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string") );
@result = $parser->parse($text);

ok eq_array(\@result, \@result_exp), "Parsing FIELD-SYMBOL failed";

################################################################################
# Test DATA + FIELD-SYMBOL
$text = "DATA: lf_i TYPE int4. DATA: lf_test011 TYPE string.";
$text .= "FIELD-SYMBOL: <lf_i> TYPE int4. FIELD-SYMBOL: <lf_test011> TYPE string.";
$text .= "DATA: lf_very_long_field TYPE string.";

@result_exp = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                SAF::Statements::Data->new("lf_test011", "TYPE", "string"),

                SAF::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                SAF::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),

                SAF::Statements::Data->new("lf_very_long_field", "TYPE", "string") );
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
    my @statements = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                       SAF::Statements::Data->new("lf_test011", "TYPE", "string") );
    @result_exp = ( SAF::Statements::Form->new("test",
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
    my @using = ( SAF::Statements::Argument->new("i_a", "TYPE", "int4"),
                  SAF::Statements::Argument->new("i_a", "TYPE", "int4"),
                  SAF::Statements::Argument->new("i_comparator", "TYPE", "string") );
    my @changing = ( SAF::Statements::Argument->new("e_result", "TYPE", "int4") );
    my @tables = ( );
    my @statements = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                       SAF::Statements::Data->new("lf_test011", "TYPE", "string") );
    @result_exp = ( SAF::Statements::Form->new("test",
                                               \@using,
                                               \@changing,
                                               \@tables,
                                               \@statements) );
}
@result = $parser->parse($text);
diag Dumper \@result;

ok eq_array(\@result, \@result_exp), "Parsing FORM with USING and CHANGING failed";
