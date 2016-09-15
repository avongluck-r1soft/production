#!/usr/bin/perl
#
# Turn off all storage locator lights prior to a drive pull / swap
#
use strict;
use warnings;

sub get_drives {
    my @eids_slots; 
    open my $in, "storcli /c0 show all|" or die "cannot open $!"; 
    while (<$in>) {
        next if $_ !~ /^[0-9]:/; 
        my @line = split;
        my $eid_slot = $line[0];
        if ($eid_slot) {
            push @eids_slots, $eid_slot; 
        }
    }
    return @eids_slots;
}

sub stop_lights {

    my @drives = get_drives();

    foreach my $drive (@drives) {
        my @line = split ':', $drive;
        my $eid  = $line[0];
        my $slot = $line[1];
        system("storcli /c0 /e$eid /s$slot stop locate"); 
    }
}

sub main() {
    stop_lights(); 
}
