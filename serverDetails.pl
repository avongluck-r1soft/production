#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use SoftLayer::API::SOAP;

my ($apiUsername, $apiKey) = get_credentials(); 

sub get_credentials {
	my $u;
	my $p;
	open my $cf, "/home/scott/.softlayer_access", or die "can't open $!"; 
	while (<$cf>) {
		my @line = split ' '; 
		$u = $line[0];
		$p = $line[1];
	}
	return $u, $p;
}

my $client = SoftLayer::API::SOAP->new('SoftLayer_Account', undef, $apiUsername, $apiKey);

$client->setObjectMask({
	'hardware'	=> {
		'operatingSystem' => {
			'passwords'	=> {},
		},
		'processors'		=> {},
		'processorCount'	=> {},
		'memory'		=>{},
		'memoryCount'		=> {},
		'networkComponents'	=> {},
		'primaryIpAddress'	=> {},
		'privateIpAddress'	=> {},
	}
});

my $hardwareRecords = $client->getHardware();

if ($hardwareRecords->fault) {
	die "Unable to retrieve hardware. ".$hardwareRecords->faultstring;
}

$hardwareRecords = $hardwareRecords->result;

for my $i (0 .. $#{$hardwareRecords}) {
	my $hardware		= $hardwareRecords->[$i];
	my $passwords		= $hardware->{operatingSystem}->{passwords};
	my $networkComponents	= $hardware->{networkComponents};
	my $processors		= $hardware->{processors};
	my $memory		= $hardware->{memory};

	my $rootUsername = '*not found*';
	my $rootPassword = '*not found*';

	for my $j (0 .. $#{$passwords}) {
		my $user = $passwords->[$j];

		if ($user->{username} eq 'root' or $user->{username} eq 'Administrator') {
			$rootUsername = $user->{username};
			$rootPassword = $user->{password};
		}
	}

	#  get public and private IP addresses
	my $publicMacAddress  = '*not found*';
	my $privateMacAddress = '*not found*';

	for my $j (0 .. $#{$networkComponents}) {
		my $component = $networkComponents->[$j];

		if ($component->{name} eq 'eth' and $component->{port} eq '0') {
			$privateMacAddress = $component->{macAddress};
		} elsif ($component->{name} eq 'eth' and $component->{port} eq '1') {
			$publicMacAddress = $component->{macAddress};
		}
	}

	my $processorType =
		$processors->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{capacity}
		.$processors->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{units}." "
		.$processors->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{description};

	my $memoryType =
		$memory->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{capacity}
		.$memory->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{units}." "
		.$memory->[0]->{hardwareComponentModel}->{hardwareGenericComponentModel}->{description};

	print <<EOT;

Hostname:		$hardware->{hostname}
Domain:			$hardware->{domain}
Login:			$rootUsername / $rootPassword
Public IP Address:	$hardware->{primaryIpAddress}
Public MAC Address:	$publicMacAddress
Private IP Address:	$hardware->{privateIpAddress}
Private MAC Address:	$privateMacAddress
CPUs:			$hardware->{processorCount}x $processorType
RAM:			$hardware->{memoryCount}x $memoryType
EOT
}





