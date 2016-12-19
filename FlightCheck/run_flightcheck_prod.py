#!/usr/bin/python

import operator
import os
import smtplib
import subprocess
import sys

from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import encoders
from subprocess import Popen,PIPE,STDOUT

def runCommand(str):
    process = Popen(args=str, stdout=PIPE, shell=True)
    return process.communicate()[0]

def runXfsFragCheck():
    runCommand("./runFlightCheckProd > runFlightCheckProd.txt 2>&1")
    
def getSMTPPassword():
    credentials = {}
    with open('../../.noreplypw','r') as f:
        for line in f:
            user, pw = line.strip().split(':')

    return pw


def emailReport(RECIPIENTS):
    fromaddr = 'noreply@r1soft.com'
    toaddr = RECIPIENTS

    msg = MIMEMultipart()

    msg['From'] = fromaddr
    msg['To'] = toaddr
    msg['Subject'] = 'Nightly production flightCheck'

    body = 'Nightly production flightCheck results (see attached).'

    msg.attach(MIMEText(body, 'plain'))

    filename = 'runFlightCheckProd.txt'

    attachment = open(filename, 'r')

    part = MIMEBase('application', 'octet-stream')
    part.set_payload((attachment).read())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', 'attachment; filename= %s' % filename)
    msg.attach(part)

    pw = getSMTPPassword()

    server = smtplib.SMTP('smtp.office365.com', 587)
    server.starttls()
    server.login(fromaddr, pw) 
    text = msg.as_string()
    server.sendmail(fromaddr, toaddr, text)
    server.quit()
    
    attachment.close()


def main():
    runXfsFragCheck()
    RECIPIENTS = 'scott.gillespie@r1soft.com,alex.vongluck@r1soft.com,stan.love@r1soft.com,tariq.siddiqui@r1soft.com'
    #RECIPIENTS = 'scott.gillespie@r1soft.com'
    emailReport(RECIPIENTS)

    
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit()


