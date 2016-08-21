#!/usr/bin/env python

from subprocess import Popen,PIPE,STDOUT

import subprocess

class color_message:
    OK   = '\033[92m'
    FAIL = '\033[91m'

def run_command(str):
    process = Popen(args=str, stdout=PIPE, shell=True)
    return process.communicate()[0]


def check_host_keys():

    FAILURES = 0

    print("Host Keys in /usr/sbin/r1soft/etc/server.allow dir:")

    installed_host_keys = run_command("ls /usr/sbin/r1soft/etc/server.allow").rstrip("\n")

    sbms = [
        "10.100.160.196", "10.109.218.21",  "10.125.31.125",  "10.148.215.82", "10.160.189.137",
        "10.160.189.149", "10.160.189.161", "10.160.189.179", "10.164.12.121", "10.164.12.82",
        "10.100.160.219", "10.122.169.173", "10.125.31.77",   "10.148.215.86", "10.160.189.143",
        "10.160.189.154", "10.160.189.166", "10.160.189.187", "10.164.12.68",  "10.164.12.97",
        "10.100.160.236", "10.125.31.116",  "10.148.215.75",  "10.160.189.132", "10.160.189.146",
        "10.160.189.156", "10.160.189.170", "10.164.12.109",  "10.164.12.75"
    ]

    for sbm in sbms:
        if sbm not in installed_host_keys:
            print color_message.FAIL + "FAIL: " + sbm + " -- host key not present in /usr/sbin/r1soft/etc/server.allow dir..."
            print color_message.FAIL + "Add key using the following command:"
            print color_message.FAIL + "wget --no-check-certificate https://" + sbm + ":8443/public_info -O /usr/sbin/r1soft/etc/server.allow/" + sbm

	    FAILURES += 1
        else: 
            print color_message.OK + "  OK: " + sbm

    return FAILURES


#
# check for r1rm and r1cm host entries
#
def check_host_entries():
 
    FAILURES = 0
    FOUND = 0

    R1HOSTS = [ "r1rm_prod.itsupport247.net", "r1cm_prod.itsupport247.net" ]

    LOCAL = []

    with open("/etc/hosts", "r") as f:
        for line in f:
            for host in R1HOSTS:
                if host in line:
                    FOUND += 1
		    LOCAL.append(host)
                    print color_message.OK + "  OK: found " + host + " in /etc/hosts file."

    if FOUND == 2:
        print color_message.OK + "  OK: found both R1 hosts in /etc/hosts file."
    else:
        for host in R1HOSTS:
            if host not in LOCAL:
                FAILURES += 1
                print color_message.FAIL + " FAIL: missing " + host + " in /etc/hosts file."

    return FAILURES

TOTAL_FAILURES = []
TOTAL_FAILURES.append(check_host_keys())
TOTAL_FAILURES.append(check_host_entries())

print color_message.FAIL + str(sum(TOTAL_FAILURES)) + " total failures in flightCheckFTP."
