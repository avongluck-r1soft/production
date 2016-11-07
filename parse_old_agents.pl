#!/usr/bin/perl 

use strict;
use warnings;
use List::Util qw(reduce); 

my @g;
my @t;

my $file = 'old_agents.csv';
open my $f, "<",  $file, or die "cannot open: $!"; 
while (<$f>) {
	my @line = split ','; 
	push @g, $line[1], if $line[1] =~ /G/;
	push @t, $line[1], if $line[1] =~ /T/; 
}

sub gtotal {

	return reduce { ($a+0.0) + ($b+0.0) } @g; 
	
	#for (@g) {
	#	s/G//;
	#	$gtotal += $_;
	#}
	#return $gtotal;
}

sub ttotal {
	my $ttotal = 0;
	for (@t) {
		s/T//;
		$ttotal += $_;
	}
	return $ttotal;
}

sub gb_to_tb {
	my $g = shift;
	return $g /= 1024;
}

my $grand_total = gb_to_tb(gtotal()) + ttotal(); 
printf "%.f TiB\n", $grand_total;

