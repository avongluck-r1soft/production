#!/usr/bin/perl 

use strict;
use warnings;

my @g;
my @t;

my $file = 'old_agents.csv';
open my $f, "<",  $file, or die "cannot open: $!"; 
while (<$f>) {
	my @line = split ','; 
	if ($line[1] =~ /G/) {
		push @g, $line[1];
	}

	if ($line[1] =~ /T/) {
		push @t, $line[1];
	}
}

my $gtotal = 0; 
for (@g) {
	s/G//; 
	$gtotal += $_; 
}

my $ttotal = 0;
for (@t) {
	s/T//; 
	$ttotal += $_; 
}

sub gb_to_tb {
	my $g = shift;
	return $g /= 1024;
}

my $grand_total = gb_to_tb($gtotal) + $ttotal; 
printf "%.f TiB\n", $grand_total;

