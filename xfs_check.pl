#!/usr/bin/perl

use strict;
use warnings;

sub get_fsname {
	my $device = shift;
	my $fsname;
	open my $cmd, "mount|", or die "cannot issue command: $!"; 
	while (<$cmd>) {
		my @data = split;
		if ($_ =~ /$device/) {
			$fsname = $data[2]; 
		}
	}
	return $fsname;
}

sub check_frag_levels {
        my $threshhold = shift;
        my @device;
        my @fraglevel;

        open my $cmd, "mount|", or die "cannot issue command: $!";
        while (<$cmd>) {
                my @line = split;
                if ($_ =~ /storage0/) {
                        my @data = split(' ', `xfs_db -c frag -r $line[0]`);
                        $data[6] =~ s/\s*\d+%$//;  # remove percent sign
                        push @device, $line[0];
                        push @fraglevel, sprintf("%.2f", $data[6]);
                }
        }
        close $cmd;

        for (my $i = 0; $i < @device; $i++) {
                if ($fraglevel[$i] > $threshhold) {
			print "\033[91mFAIL - ".get_fsname($device[$i])." ".$fraglevel[$i]."\n"; 
                } else {
			print "\033[92mOK   - ".get_fsname($device[$i])." ".$fraglevel[$i]."\n"; 
		}
        }
}

check_frag_levels(75.0); 

