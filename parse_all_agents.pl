#!/usr/bin/perl 

use strict;
use warnings;
use List::Util qw(reduce); 

my @g;
my @t;
my @k;

my $file = 'ds1.csv';
open my $f, "<",  $file, or die "cannot open: $!"; 
while (<$f>) {
	my @line = split ','; 
	push @g, $line[1], if $line[1] =~ /G/;
	push @t, $line[1], if $line[1] =~ /T/; 
	push @k, $line[1], if $line[1] =~ /K/; 
}

sub ktotal {
	my @digits = map { (my $x = $_) =~ tr/K//d; $x} @k;
	return reduce { $a + $b } @digits;
}

sub gtotal {
	my @digits = map { (my $x = $_) =~ tr/G//d; $x } @g;
	return reduce { $a + $b } @digits; 
}

sub ttotal {
	my @digits = map { (my $x = $_) =~ tr/T//d; $x } @t;
	return reduce { $a + $b } @digits;
}

sub kb_to_mb {
	my $k = shift;
	if ($k) {
		return $k /= 1024;
	}
	return 0;
}

sub mb_to_gb {
	my $m = shift;
	if ($m) {
		return $m /= 1024;
	}
	return 0;
}

sub gb_to_tb {
	my $g = shift;
	if ($g) {
		return $g /= 1024;
	}
	return 0;
}

my $grand_total = gb_to_tb(mb_to_gb(kb_to_mb(ktotal()))) + gb_to_tb(gtotal()) + ttotal(); 
#my $grand_total = gb_to_tb(kb_to_mb(ktotal())) + gb_to_tb(gtotal()) + ttotal(); 
printf "%.f TiB\n", $grand_total;

