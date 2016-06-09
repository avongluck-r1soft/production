#!/usr/bin/python

max_open_files = warning_level = 20000
#max_open_files = warning_level = 500

def check_open_files():
    count = 0
    with open('/proc/sys/fs/file-nr') as f:
        for line in f:
            line = line.split()
            count = line[0]
    return count

num_open = check_open_files()

if int(num_open) > warning_level:
    print "warning: too many open files... "+num_open
else:
    print num_open+" open files."
            
         
    
