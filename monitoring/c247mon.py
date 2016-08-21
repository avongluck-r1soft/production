#!/usr/bin/python

from datetime import datetime
from subprocess import Popen,PIPE,STDOUT

import contextlib
import commands
import filecmp
import time
import socket
import multiprocessing
import logging
import logging.handlers
import os 
import subprocess
import sys


""" globals BEGIN """
hostname = socket.gethostname()

def get_ip_address(hostname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

ip_addr = get_ip_address(hostname)

HIGH_CPU_COUNT = 0
""" globals END """


def get_system_type():
    if os.path.exists("/opt/r1soft/r1rm/bin/r1rm"):
        return "r1rm"
    if os.path.exists("/opt/r1soft/r1cm/bin/r1cm"):
        return "r1cm"
    if os.path.exists("/opt/r1soft/ftp/home"):
        return "ftp"
    if os.path.exists("/usr/sbin/r1soft/bin/cdpserver"):
        return "csbm"
    if os.path.exists("/etc/sysctl.d/cassandra.conf"):
        return "cassandra"
    return "unknown"

def run_command(str):
    process = Popen(args=str, stdout=PIPE, shell=True)
    return process.communicate()[0]

def check_cpu(THRESHHOLD):
    global HIGH_CPU_COUNT 
    cpu_usage = run_command("top -bn5|awk \'/Cpu/{sum+=$2}END{print sum/5}\'")

    if float(cpu_usage) > THRESHHOLD:
        log_event("High CPU usage on : " + hostname + " ip: " + ip_addr)
        HIGH_CPU_COUNT += 1

    if HIGH_CPU_COUNT >= 10:
        log_event("DEVOPS -- WARNING " + hostname + " " + ip_addr + " ")
        log_event("Prolonged high CPU usage on : " + hostname + " ip: " + ip_addr)

    return float(cpu_usage)


def log_event(msg):
    print(msg)
    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)
    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)
  
    
def check_swapspace(THRESHHOLD):
    swap_inuse = run_command("swapon -s | awk '/dev/ {print ($4/$3 * 100.0)}'")

    if float(swap_inuse) > THRESHHOLD:
        log_event("DEVOPS -- WARNING " + hostname + " " + ip_addr + " ")
        log_event("High swap usage on : " + hostname + " ip: " + ip_addr)

    return float(swap_inuse)


def check_diskspace(THRESHHOLD):
    DF_OUTPUT = {}

    with open("/proc/mounts", "r") as f:
        for line in f:
            fs_spec, fs_file, fs_vfstype, fs_mntops, fs_freq, fs_passno = line.split()
            if fs_spec.startswith('/'):
                r = os.statvfs(fs_file)
                block_usage_pct = 100.0 - (float(r.f_bavail) / float(r.f_blocks) * 100)

                DF_OUTPUT[fs_file] = block_usage_pct
      
                if float(block_usage_pct) > THRESHHOLD:
                    print("DEVOPS -- " + hostname + " ALERT! " + str(fs_file) + " -> " + str(block_usage_pct))
                    log_event("DEVOPS -- " + hostname + " ALERT " + str(fs_file) + " -> " + str(block_usage_pct))

    return DF_OUTPUT


def restart_service(name):
    restartcmd = ['service', name, 'restart']
    subprocess.call(restartcmd, shell=False)
    log_event(name + " service restarted on " + hostname)


def check_service_running(name):
    p = Popen(["service", name, "status"], stdout=PIPE)
    output = p.communicate()[0]
    
    if p.returncode != 0:
        log_event("DEVOPS -- Service " + name + " is DOWN on " + hostname + ".")
        restart_service(name)
        return name + " is DOWN on " + hostname

    return name + " is UP on " + hostname


def check_num_processes(THRESHHOLD):
    num_procs = run_command('ps -dfeal|wc -l')

    if int(num_procs) > THRESHHOLD:
        log_event("DEVOPS -- high number of processes on " + hostname + " : " + num_procs)

    return int(num_procs)


def check_max_open_files(THRESHHOLD):
    with open ("/proc/sys/fs/file-nr") as f:
        for line in f:
            allocated, free, maximum, = line.split()

    if int(allocated) > THRESHHOLD:
        log_event("DEVOPS -- high number of open files on " + hostname + " : " + str(allocated))

    #return allocated, free, maximum
    return allocated

def check_num_sockets(THRESHHOLD):
    num_sockets = run_command('netstat -na|wc -l')

    if int(num_sockets) > THRESHHOLD:
        log_event("DEVOPS -- high number of open network connections on " + hostname + " : " + str(num_sockets))
    
    return int(num_sockets)

def check_ufw_rules():
    os.system('ufw status > /tmp/.ufw_status')
    ret = filecmp.cmp("/tmp/.ufw_status", "/opt/r1soft/devops/rules")
    if ret == False:
        log_event("DEVOPS -- ufw incorrectly configured on " + hostname) 
        return "ufw status BROKEN on " + hostname

    return "ufw status OK on " + hostname
        
def main():

    MAX_CPU        = 75
    MAX_DISK       = 70
    MAX_SWAP       = 25
    MAX_OPEN_FILES = 20000
    MAX_SOCKETS    = 20000
    MAX_PROCS      = 2500

    running = True
    system_type = get_system_type()

    while running:
        now = str(datetime.now())
        print("\n############### " + now + " ###############\n")

        print("hostname              = " + hostname)
        print("system_type           = " + system_type)
        print("ip_address            = " + ip_addr)
        print("check_cpu             = " + str(check_cpu(MAX_CPU)))
        print("check_swapspace       = " + str(check_swapspace(MAX_SWAP)))
        print("check_diskspace       = " + str(check_diskspace(MAX_DISK)))
        print("check_num_processes   = " + str(check_num_processes(MAX_PROCS)))
        print("check_max_open_files  = " + str(check_max_open_files(MAX_OPEN_FILES)))
        print("check_num_sockets     = " + str(check_num_sockets(MAX_SOCKETS)))
        
        if system_type == "r1rm":
            print("check_service_running = " + str(check_service_running("r1rm")))
            print("check_service_running = " + str(check_service_running("apparmor")))

        if system_type == "r1cm":
            print("check_service_running = " + str(check_service_running("r1cm")))
            print("check_service_running = " + str(check_service_running("apparmor")))

        if system_type == "csbm":
            print("check_service_running = " + str(check_service_running("r1ctl")))
            print("check_service_running = " + str(check_service_running("cdp-server")))
            print("check_service_running = " + str(check_service_running("virtualbox")))
            print("check_service_running = " + str(check_service_running("apparmor")))

        if system_type == "cassandra":
            print("check_service_running = " + str(check_service_running("cassandra")))

        if system_type == "ftp":
            print("check_service_running = " + str(check_service_running("proftpd")))

        # These services should be running everywhere.
        print("check_service_running = " + str(check_service_running("networking")))
        print("check_service_running = " + str(check_service_running("ssh")))
        print("check_service_running = " + str(check_service_running("fail2ban")))
        print("check_service_running = " + str(check_service_running("rsyslog")))
        print("check_service_running = " + str(check_service_running("ufw")))
	
	if os.path.exists("/opt/r1soft/devops/rules"):
            print("check_ufw_rules       = " + str(check_ufw_rules()))

        time.sleep(60)


if __name__ == "__main__":
    main()
