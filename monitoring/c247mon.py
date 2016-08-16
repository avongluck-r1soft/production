#!/usr/bin/python

from datetime import datetime
import time
import socket
import multiprocessing
import psutil
import logging
import logging.handlers

""" 
globals begin 
hostname = socket.gethostname()
ip_addr  = get_ip_address(hostname)
globals end  
"""

def main():

    hostname = socket.gethostname()
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
        #print("check_swapspace = " + check_swapspace())

        time.sleep(60)

def get_ip_address(hostname):
    
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

def check_cpu(MAX_HIGH_CPU, HIGH_CPU_COUNT):
    
    usage = psutil.cpu_percent()

    if usage > MAX_HIGH_CPU:
        HIGH_CPU_COUNT = HIGH_CPU_COUNT + 1

        if HIGH_CPU_COUNT >= MAX_HIGH_CPU_COUNT:
            log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")

    return usage


def log_event(msg):

    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)

    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)
  
    
#def check_swapspace():


if __name__ == "__main__":
    main()

