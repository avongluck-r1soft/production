#!/usr/bin/perl 

use strict;
use warnings;

my @g;
my @t;

my $file = 'old_agents_deleted.txt';
open my $f, "<",  $file, or die "cannot open: $!"; 
while (<$f>) {
	my @line = split;
	if ($line[0] =~ /G/) {
		push @g, $line[0];
	}

	if ($line[0] =~ /T/) {
		push @t, $line[0];
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

