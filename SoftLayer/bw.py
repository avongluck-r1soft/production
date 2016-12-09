#!/usr/bin/python

import SoftLayer
import pprint

def getPublicBandwidth():

    threshhold = 1000.0 

    client = SoftLayer.Client()
    pp = pprint.PrettyPrinter(indent=2)
    theMask = "mask[outboundPublicBandwidthUsage]"
    result = client['SoftLayer_Account'].getHardware()
    print "server_name,public_out\n"
        
    for server in result:

        serverInfo = client['SoftLayer_Hardware_Server'].getObject(id=server['id'],mask=theMask)
        pubout = float(serverInfo.get('outboundPublicBandwidthUsage',0.0))

	if pubout > threshhold:
            print(serverInfo['fullyQualifiedDomainName'] + ","),
	    print("Warning! " + str(pubout))
	
getPublicBandwidth()
