#!/bin/bash
#
# 53PortAwail.sh - execute custom event when 53 port goes down.
#

# _prerequirements:
(crontab -l && echo "* * * * * /bin/bash /opt/53PortAwail.sh >/dev/null 2>&1") | crontab -


###cat <<EOF >/opt/53PortAwail.sh

# get port status
if [[ `netstat -nau | grep -o ":53\W"` =~ ":53" ]]; then
	#
	# do not write if value same
	if [[ `cat "/proc/sys/net/ipv4/icmp_echo_ignore_all"` == "1" ]]; then
		echo "0" > "/proc/sys/net/ipv4/icmp_echo_ignore_all"
	fi
else
	#
	# do not write if value same
	if [[ `cat "/proc/sys/net/ipv4/icmp_echo_ignore_all"` == "0" ]]; then
		echo "1" > "/proc/sys/net/ipv4/icmp_echo_ignore_all"
	fi
fi
###EOF

chmod +x /opt/53PortAwail.sh
