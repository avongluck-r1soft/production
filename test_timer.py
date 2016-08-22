#!/usr/bin/env python

import time
import sys
import logging
import logging.handlers

def main():
    LOG_TIMEOUT = 1200
    msg = "this is a test log event - time -> "

    running = True
    while running:
        log_event(msg)
        time.sleep(60)

def log_event(msg):

    now = time.time()
    print(msg + str(now))

    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)
    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit()

