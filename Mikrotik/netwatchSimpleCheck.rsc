#
# netwatchSimpleCheck.rsc - just check host.
#
# https://<>

# _prerequirements:



========

# _VARS:
<HOST>

========
/tool netwatch
add down-script="/log error \"<HOST> host DOWN\"" host=<HOST> interval=1s timeout=500ms up-script=\
    "/log error \"<HOST> host UP\""

========
