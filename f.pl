#!/usr/bin/perl

use strict;
use warnings;

sub factorial {
        my $n = shift;
        return 1 if $n == 0;
        return factorial($n-1)*$n;
}

sub summation {
        my $n = shift;
        return 1 if $n == 1;
        return summation($n-1)+$n;
}

print factorial(5), "\n";
print summation(5), "\n";

