#!/usr/bin/perl

# guf.pl - get uuid / filesystem pairs after a drive failure.

use strict;
use warnings;
use autodie;

open my $agents, "</root/agents";
open my $out, ">/root/failed_drive_agents";
while (<$agents>) {
    print $out, getDiskSafe $_;
}
close $out;
close $agents;

my @uuids;
my @filesystems;

open my $f, "</root/failed_drive_agents";
while (<$f>) {
    push @uuids, if /information/;
    push @filesystems, if /storage0/;
}
close $f;

open my $csv, ">/root/failed_drive_uuids.csv"; 
my $total = $#uuids;
for (my $i=0; $i <= $total; $i++) {
    print $csv, "$uuids[$i], $filesystems[$i]\n";
}
