#!/usr/bin/python

from datetime import datetime
import time
import socket
import multiprocessing
import psutil


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
        print("check_cpu       = " + str(check_cpu()))
        #print("check_swapspace = " + check_swapspace())

        time.sleep(60)

def get_ip_address(hostname):
    
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

def check_cpu():
    
    cpu_used = psutil.cpu_percent()

    #if cpu_used > MAX_HIGH_CPU:
    #    HIGH_CPU_COUNT = HIGH_CPU_COUNT + 1
    #    if HIGH_CPU_COUNT >= MAX_HIGH_CPU_COUNT:
            

    return cpu_used
  
    
#def check_swapspace():


if __name__ == "__main__":
    main()

