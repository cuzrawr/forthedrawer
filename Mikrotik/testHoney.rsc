
#
# testHoney.rsc - just collect IPs and block as dumb.
#
# https://<>

# _prerequirements:

# optimise this shit

========

# _VARS:
<THISLISTNAME>
<INCOMINGPORTS>

========

/add action=add-src-to-address-list address-list=<THISLISTNAME> address-list-timeout=none-static chain=input dst-port=<INCOMINGPORTS> in-interface-list=WAN protocol=tcp
#
/add action=drop chain=prerouting in-interface-list=WAN src-address-list=<THISLISTNAME>

========



