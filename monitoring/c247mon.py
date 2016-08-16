#!/usr/bin/python

from datetime import datetime
import contextlib
import time
import socket
import multiprocessing
import psutil
import logging
import logging.handlers
import os 
import sys

""" globals begin """
hostname = socket.gethostname()

def get_ip_address(hostname):
    
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

ip_addr  = get_ip_address(hostname)

""" globals end  """

def main():

    #hostname = socket.gethostname()
    ip_addr  = get_ip_address(hostname)
    MAX_USED_SWAP      = 25
    HIGH_CPU_COUNT     = 0
    MAX_HIGH_CPU_COUNT = 10  
    MAX_HIGH_CPU       = 75
    MAX_DISKSPACE_PCT  = 70
    MAX_OPEN_FILES     = 20000
    MAX_SOCKETS        = 20000
    MAX_PROCS          = 2500
    MAX_CM_QUEUE       = 300

    running = True

    while running:

        now = str(datetime.now())
        print("\n########### " + now + " ###########\n")
        print("hostname        = " + hostname)
        print("ip_address      = " + ip_addr)
        print("check_cpu       = " + str(check_cpu(MAX_HIGH_CPU, HIGH_CPU_COUNT)))
        print("check_swapspace = " + str(check_swapspace(MAX_USED_SWAP)))
        print("check_diskspace = " + str(check_diskspace(MAX_DISKSPACE_PCT)))

        time.sleep(60)

def check_cpu(MAX_HIGH_CPU, HIGH_CPU_COUNT):
    
    usage = psutil.cpu_percent()

    if usage > MAX_HIGH_CPU:
        HIGH_CPU_COUNT = HIGH_CPU_COUNT + 1

        if HIGH_CPU_COUNT >= MAX_HIGH_CPU_COUNT:
            log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")
            log_event("High CPU usage on : " + hostname + " ip: " + ip_addr)

    #log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")
    return usage


def log_event(msg):

    print("#### DEVOPS WARNING ####")
    print("sending the following message to /var/log/syslog:")
    print(msg)
    print("#### DEVOPS WARNING ####")
    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)

    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)
  
    
def check_swapspace(MAX_USED_SWAP):

    swap_inuse = psutil.swap_memory()

    if swap_inuse.percent > MAX_USED_SWAP:
        log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")
        log_event("High swap usage on : " + hostname + " ip: " + ip_addr)

    return swap_inuse.percent

def check_diskspace(MAX_DISKSPACE_PCT):

    with open("/proc/mounts", "r") as f:
        for line in f:
            fs_spec, fs_file, fs_vfstype, fs_mntops, fs_freq, fs_passno = line.split()
            if fs_spec.startswith('/'):
                r = os.statvfs(fs_file)
                block_usage_pct = 100.0 - (float(r.f_bavail) / float(r.f_blocks) * 100)

                if block_usage_pct > MAX_DISKSPACE_PCT:
                    log_event("disk_space_/" + fs_spec + "DiskUsage high = " + block_usage_pct + " mount_point = " + fs_file)

                print "%s\t%s\t\t%d%%" % (fs_spec, fs_file, block_usage_pct)
                 
                
if __name__ == "__main__":
    main()
