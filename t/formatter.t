=encoding utf-8

=head1 NAME

format.t - Unittests for ABAPMonk::Formatter

=cut

use strict;
use warnings;
use utf8;

use Test::More;
use Data::Dumper;

plan tests => 3;

use ABAPMonk::Formatter;
use ABAPMonk::Statements::Data;
use ABAPMonk::Statements::FieldSymbol;
use ABAPMonk::Statements::CommentBlock;
use ABAPMonk::Statements::Form;

my $formatter = ABAPMonk::Formatter->new;
my @statements = ( );
my $result= 0;
my $result_exp = 1;

################################################################################
# Test DATA
@statements = ( ABAPMonk::Statements::CommentBlock->new(["This is a very long comment containing many symbols that will eventually result in a line wrap.",
                                                    "",
                                                    "Also this should be on a complete new line."]),
                ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string"),
                ABAPMonk::Statements::Data->new("lf_very_long_field", "TYPE", "string"),
                ABAPMonk::Statements::CommentBlock->new(["Trailing comment.",
                                                    "Will be on one line."]) );
$result_exp = '';
$result_exp .= '* This is a very long comment containing many symbols that will eventually' . "\n";
$result_exp .= '* result in a line wrap.' . "\n";
$result_exp .= '*' . "\n";
$result_exp .= '* Also this should be on a complete new line.' . "\n";
$result_exp .= "DATA: lf_i               TYPE int4." . "\n";
$result_exp .= "DATA: lf_test011         TYPE string." . "\n";
$result_exp .= "DATA: lf_very_long_field TYPE string." . "\n";
$result_exp .= '* Trailing comment. Will be on one line.';

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting DATA failed";

################################################################################
# Test FIELD-SYMBOL
@statements = ( ABAPMonk::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                ABAPMonk::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),
                ABAPMonk::Statements::FieldSymbol->new("<lf_very_long_field>", "TYPE", "string") );
$result_exp = '';
$result_exp .= "FIELD-SYMBOLS: <lf_i>               TYPE int4." . "\n";
$result_exp .= "FIELD-SYMBOLS: <lf_test011>         TYPE string." . "\n";
$result_exp .= "FIELD-SYMBOLS: <lf_very_long_field> TYPE string.";

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting FIELD-SYMBOL failed";

#################################################################################
# Test DATA + FIELD-SYMBOL
@statements = ( ABAPMonk::Statements::Data->new("lf_i", "TYPE", "int4"),
                ABAPMonk::Statements::Data->new("lf_test011", "TYPE", "string"),

                ABAPMonk::Statements::FieldSymbol->new("<lf_i>", "TYPE", "int4"),
                ABAPMonk::Statements::FieldSymbol->new("<lf_test011>", "TYPE", "string"),

                ABAPMonk::Statements::Data->new("lf_very_long_field", "TYPE", "string") );
$result_exp = '';
$result_exp .= "DATA: lf_i                  TYPE int4." . "\n";
$result_exp .= "DATA: lf_test011            TYPE string." . "\n";
$result_exp .= "\n";
$result_exp .= "FIELD-SYMBOLS: <lf_i>       TYPE int4." . "\n";
$result_exp .= "FIELD-SYMBOLS: <lf_test011> TYPE string." . "\n";
$result_exp .= "\n";
$result_exp .= "DATA: lf_very_long_field    TYPE string.";

$result = $formatter->format(@statements);
is $result, $result_exp, "Formatting DATA + FIELD-SYMBOL failed";
