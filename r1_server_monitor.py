#!/usr/bin/python

max_open_files = 20000

def check_open_files(n):
    count = 0
    warning_level = n
    with open('/proc/sys/fs/file-nr') as f:
        for line in f:
            line = line.split(' ')
            count = line[0]

    if count > warning_level:
        print "Too many open files. "+count

    return count

print "check_open_files="+check_open_files(max_open_files)
            
         
    
