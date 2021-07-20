use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SAF',
    AUTHOR              => 'Richard Bäck <richard.baeck@mailbox.org>',
    LICENSE             => 'MIT',
    PL_FILES            => { },
    EXE_FILES           => [
        "bin/saf.pl"
    ],
    PREREQ_PM           => {
        'Test::More'    => 0,
    },
    dist                => {
        COMPRESS => 'gzip -9f',
        SUFFIX => 'gz' },
);
