#!/usr/bin/perl

use strict; 
use warnings; 

sub get_fs_inuse {
    my $cmd = "df -h|awk '/jenkins/ {print \$5}' | sed 's/%//g'"; 
    `$cmd`; 
}

sub main {
    my $threshhold = 96;
    my $inuse = get_fs_inuse(); 
    if ($inuse >= $threshhold) {

}

main(); 

