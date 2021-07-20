#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use SAF::Parser;
use SAF::Formatter;

my $text = '';
if (scalar @ARGV > 0) {
    open my $in_fh, '<:encoding(UTF-8)', $ARGV[0];
    $/ = undef;
    $text = <$in_fh>;
    close $in_fh;
} else {
    while (<>) {
        $text .= $_;
    }
}

my $parser = SAF::Parser->new;
my $formatter = SAF::Formatter->new;

my @statements = $parser->parse($text);
my $formatted_text = $formatter->format(@statements);
print $formatted_text;
