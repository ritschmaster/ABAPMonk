package ABAPMonk::Statements::CommentBlock;

use strict;
use warnings;

use ABAPMonk::Statement;

our @ISA = qw(Statement);

sub new {
    my ($class, $text_lines_ref) = @_;

    my $self = $class->SUPER::new;

    $self->{ _text_lines_ref } = $text_lines_ref;

    bless $self, $class;

    return $self;
}
use Test::More;
use Data::Dumper;
sub _simple_format {
    my ($self) = @_;

    my $formatted = "";

    my @text_lines = @{ $self->{ _text_lines_ref } };
    my $line = "*";
    my @remaining_words = ( );
    for (my $i = 0; $i < scalar @text_lines; $i++) {
        my $text_line = $text_lines[$i];

        if ($text_line eq ""
            || $text_line =~ m/^\s$/) {
            $formatted .= "\n" if (length $formatted > 0);

	    if (length $line ne "*") {
		    $formatted .= $line . "\n";
		    $line = "*";
	    }

            $formatted .= "*";
        } else {
            my @words = split(/ /, $text_line);

            while (scalar @words > 0) {
                my @remaining_words = ( );

		my $len_reached = 0;
		foreach my $word (@words) {
                    if (!$len_reached) {
			if (length $line . " " . $word <= 80) {
                      	    $line .= " " .$word;
			} else {
			    $len_reached = 1;
		    	}
                    }

		    if ($len_reached) {
                        push @remaining_words, $word;
                    }
                }

		@words = @remaining_words;
                if (scalar @remaining_words > 0
		    || $i + 1 >= scalar @text_lines) {
                    $formatted .= "\n" if length $formatted > 0;
                    $formatted .= $line;

		    $line = "*";
                }
            }
        }
    }

    return $formatted;
}

sub _complex_format {
    my ($self) = @_;

    return $self->_simple_format();
}

1;
