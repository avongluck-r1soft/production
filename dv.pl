#!/usr/bin/perl

use strict;
use warnings;
use autodie;

my @filesystems = glob "/storage0*/replication";
foreach my $fs (@filesystems) {
    chdir $fs;
    open my $cmd, "du -sh *|", or die "cannot open $!";
    while (<$cmd>) {
        print "$fs \t$_", if /[0-2].[0-9]T/;
    }
    close $cmd;
}
