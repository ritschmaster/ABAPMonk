use strict;
use warnings;

use Test::More;
use Data::Dumper;

plan tests => 3;

use SAF::Parser;
use SAF::Statements::Data;
use SAF::Statements::FieldSymbol;

my $parser = SAF::Parser->new;
my $text = "";
my @result = ( 0 );
my @result_exp = ( 1 );

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
