#!/usr/bin/perl

use strict; 
use warnings; 
use Net::SSH::Perl;
use autodie;

my @prodhosts;

my $user = 'continuum';
my $pass = ''; 

open my $cmd, "slcli hardware list|"; 
while (<$cmd>) {

    my @data = split ' '; 

    next if /ALL/;
    next if /159.122.244.142/;
    next if /159.122.244.141/;
    next if /159.122.244.132/;
    next if /159.122.244.138/;
    next if /169.54.24.105/;

    push @prodhosts, $data[2] if /sbm/;
}
close $cmd;

my $cmd1 = "curl -X GET http://localhost:81/version"; 
my $cmd2 = "curl -X GET http://localhost:81/r1rm/version";

foreach my $host (@prodhosts) {
    my $ssh = Net::SSH::Perl->new($host, debug=>0);
    $ssh->login("$user", "$pass");
    my ($stdout1, $stderr1, $exit1) = $ssh->cmd("$cmd1");
    my ($stdout2, $stderr2, $exit2) = $ssh->cmd("$cmd2"); 
    chomp $stdout1;
    chomp $stdout2;
    print "host: $host\t sbm: $stdout1\t r1rm: $stdout2";
    print "\n";
}
