#!/usr/bin/python

import SoftLayer
import pprint

total_out = []

def getPublicBandwidth():

    threshhold = 1000.0 

    client = SoftLayer.Client()
    pp = pprint.PrettyPrinter(indent=2)
    theMask = "mask[outboundPublicBandwidthUsage]"
    result = client['SoftLayer_Account'].getHardware()

    for server in result:

        serverInfo = client['SoftLayer_Hardware_Server'].getObject(id=server['id'],mask=theMask)
        pubout = float(serverInfo.get('outboundPublicBandwidthUsage',0.0))

	if pubout > threshhold:
            total_out.append(pubout)
            print(serverInfo['fullyQualifiedDomainName'] + ", "),
	    print(str(pubout))
	
getPublicBandwidth()
print "total: " + str(sum(total_out))
print "price: $" + str(sum(total_out)*0.09)
