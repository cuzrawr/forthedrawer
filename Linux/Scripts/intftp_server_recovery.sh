# to run tftp daemon in foreground:
# /usr/bin/in.tftpd --foreground --ipv4 --verbosity 9 --verbose --secure $(pwd)
#

# check root rights
#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root" 
#   exit 1
#fi

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C. Please wait. Killing in.tftpd process..."
        killall -9 "in.tftpd"
	#tset
	exit 0
}


# /usr/bin/in.tftpd - should be present in system ( install tftp-hpa )

# to see logs:
# journalctl -xef | grep -i tftp
