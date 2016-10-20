
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

        my $failcount = 0;
        for (my $i = 0; $i < @device; $i++) {
                if ($fraglevel[$i] > $threshhold) {
                        my $s = " check_frag_levels - fragmentation level high for device: $device[$i] -> $fraglevel[$i] ";
                        my $logmsg = "DEVOPS -- WARNING $HOSTNAME ($IP) ".$s;
                        my $cmd = "logger \"$logmsg\"";
                        system($cmd);
                        print "$logmsg\n";
                        $failcount++;
                }
        }
        if ($failcount != 0) {
                return "FAIL";
        } else {
                return "OK";
        }
}

