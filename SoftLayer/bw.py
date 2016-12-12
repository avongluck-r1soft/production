#!/usr/bin/python

import csv
import operator
import pprint
import smtplib
import sys
import SoftLayer

from email.mime.text import MIMEText 

total_out = []

def getPublicBandwidth():

    #threshhold = 500.0
    threshhold = 0.0

    client = SoftLayer.Client()
    theMask = "mask[outboundPublicBandwidthUsage]"
    result = client['SoftLayer_Account'].getHardware()

    f = open('public_outbound.csv','w')
    for server in result:

        serverInfo = client['SoftLayer_Hardware_Server'].getObject(id=server['id'],mask=theMask)
        pubout = float(serverInfo.get('outboundPublicBandwidthUsage',0.0))
        name = serverInfo['fullyQualifiedDomainName']

	if pubout > threshhold:

            total_out.append(pubout)
            print(name + "," + str(pubout))
            s = name + "," + str(pubout) + "\n"
            f.write(s)

    f.close()


def getTotal():
    print "total: " + str(sum(total_out))
    print "price: $" + str(round(sum(total_out)*0.09,2))


def sortCsv():
    data = csv.reader(open('public_outbound.csv'), delimiter=',')
    sortedlist = sorted(data, key=lambda x: float(x[1]), reverse=True)

    with open('public_outbound_sorted.csv','wb') as f:
        fileWriter = csv.writer(f, delimiter=',')
        for row in sortedlist:
            fileWriter.writerow(row)

def emailSortedCsv():
    with open('public_outbound_sorted.csv') as fp:
        msg = MIMEText(fp.read())

    msg['Subject'] = 'softlayer public outbound bandwidth usage'
    msg['From'] = 'scott.gillespie@r1soft.com'
    msg['To'] = 'scott.gillespie@r1soft.com'

    s = smtplib.SMTP('smtp.office365.com')
    s.send_message(msg)
    s.quit()


def main():
    getPublicBandwidth()
    getTotal()
    sortCsv()
    #emailSortedCsv() 

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit()


