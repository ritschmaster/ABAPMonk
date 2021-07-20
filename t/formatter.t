use strict;
use warnings;

use Test::More;
use Data::Dumper;

plan tests => 3;

use SAF::Formatter;
use SAF::Statements::Data;
use SAF::Statements::FieldSymbol;

my $formatter = SAF::Formatter->new;
my @statements = ( );
my $result= 0;
my $result_exp = 1;

################################################################################
# Test DATA
@statements = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                SAF::Statements::Data->new("lf_test011", "TYPE", "string"),
                SAF::Statements::Data->new("lf_very_long_field", "TYPE", "string") );
$result_exp = '';
$result_exp .= "DATA: lf_i               TYPE int4." . "\n";
$result_exp .= "DATA: lf_test011         TYPE string." . "\n";
$result_exp .= "DATA: lf_very_long_field TYPE string.";

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting DATA failed";

################################################################################
# Test FIELD-SYMBOL
@statements = ( SAF::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                SAF::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),
                SAF::Statements::FieldSymbol->new("<lf_very_long_field>", "TYPE", "string") );
$result_exp = '';
$result_exp .= "FIELD-SYMBOL: <lf_i>               TYPE int4." . "\n";
$result_exp .= "FIELD-SYMBOL: <lf_test011>         TYPE string." . "\n";
$result_exp .= "FIELD-SYMBOL: <lf_very_long_field> TYPE string.";

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting FIELD-SYMBOL failed";

#################################################################################
# Test DATA + FIELD-SYMBOL
@statements = ( SAF::Statements::Data->new("lf_i", "TYPE", "int4"),
                SAF::Statements::Data->new("lf_test011", "TYPE", "string"),

                SAF::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                SAF::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),

                SAF::Statements::Data->new("lf_very_long_field", "TYPE", "string") );
$result_exp = '';
$result_exp .= "DATA: lf_i                 TYPE int4." . "\n";
$result_exp .= "DATA: lf_test011           TYPE string." . "\n";
$result_exp .= "\n";
$result_exp .= "FIELD-SYMBOL: <lf_i>       TYPE int4." . "\n";
$result_exp .= "FIELD-SYMBOL: <lf_test011> TYPE string." . "\n";
$result_exp .= "\n";
$result_exp .= "DATA: lf_very_long_field   TYPE string.";

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting DATA + FIELD-SYMBOL failed";
