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

my %hosts_addresses;
@hosts_addresses{@hosts} = @addresses;

my @dighosts;
my @digaddresses;

sub lookup {
	my $host = shift;
	open my $cmd, "dig $host.itsupport247.net|", or die "cannot run command\n"; 
	while (<$cmd>) {
		my @line = split;
		if ($_ =~ /^$host.itsupport247.net/) {
			my @data = split("."); 
		 	$line[0] =~ s/itsupport247\.net\.//g; 
			$line[0] =~ s/\.$//; 
			print "$line[0] $line[4]\n"; 
		}
	}
	close $cmd;
}

my %dighosts_addresses;
@dighosts_addresses{@dighosts} = @digaddresses;

for (keys %hosts_addresses) {
	unless (exists $dighosts_addresses{$_}) {
		print "$_: not found in second hash\n"; 
		next;
	}
	if ($hosts_addresses{$_} eq $dighosts_addresses{$_}) {
		print "$_: values are equal\n";
	} else {
		print "$_: values are not equal\n";
	}
}

for (my $i = 0; $i < @hosts; $i++) {
	print "$hosts[$i] $addresses[$i]\n"; 
	lookup($hosts[$i]); 
}




