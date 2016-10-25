#!/usr/bin/perl

my @hosts;
my @addresses;

open my $cmd, "slcli hardware list|", or die "cannot run command\n"; 
while (<$cmd>) {
	my @line = split;
	push @hosts, $line[1]; 
	push @addresses, $line[2]; 
}
close $cmd;

sub lookup {
	my $host = shift;
	open my $cmd, "dig $host.itsupport247.net|", or die "cannot run command\n"; 
	while (<$cmd>) {
		my @line = split;
		if ($_ =~ /^$host.itsupport247.net/) {
		 	$line[0] =~ s/itsupport247\.net\.//g; 
			$line[0] =~ s/\.$//; 
			my $s = "$line[0] $line[4]"; 
			return $s;
		}
	}
	close $cmd;

	return "WARN: public dns A record not found for $host";
}

for (my $i = 0; $i < @hosts; $i++) {
	my $s = lookup($hosts[$i]); 
	my @data = split / /, $s;
	if ($addresses[$i] == $data[1]) {
		print "\033[92mOK   - softlayer: $hosts[$i] $addresses[$i] \t\t dns: $s\n"; 
	} else {
		print "\033[91mWARN - softlayer: $hosts[$i] $addresses[$i] \t\t dns: $s\n"; 
	}
	print "\033[0m";
}
