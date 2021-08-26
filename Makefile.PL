use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ABAPMonk',
    AUTHOR              => 'Richard Bäck <richard.baeck@mailbox.org>',
    LICENSE             => 'MIT',
    PL_FILES            => { },
    EXE_FILES           => [
        "bin/abapmonk.pl"
    ],
    PREREQ_PM           => {
        'Test::More'    => 0,
    },
    dist                => {
        COMPRESS => 'gzip -9f',
        SUFFIX => 'gz' },
);
