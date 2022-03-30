################################server########################################

[Interface]
#Address = 10.0.0.1/24   (wg iface)
ListenPort = 9955
PrivateKey = 6MRVGgnT2YVwA1cB3vQClh3M7yHqxjEleUmT5j7ZL3M=
#PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = aTJL7PyAj8qZeVXzOeU/vK7uaZz/5c9WWKWjoiVhFxE=
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = BLJoIJvKWLzHMG9XqN/DVC5Ebd/4ETDDtBHCbBaQuV4=
AllowedIPs = 10.0.0.3/32

[Peer]
PublicKey = BLJoIJvKWLzHMG9XqN/DVC5Ebd/4ETDDtBHCbBaQuV4=
AllowedIPs = 10.0.0.3/32

[Peer]
PublicKey = jX+rhNw7MGM69mz0OqPR4G4xXPRUkKyCRAN+E/Yr800=
AllowedIPs = 10.0.0.4/32

[Peer]
PublicKey = ly+w5REIwkSQxkK5yrskK95goMx5GfhDn9xcjG7GI04=
AllowedIPs = 10.0.0.5/32

[Peer]
PublicKey = pp/6s73O5SoO80p8qxrDIbVU8TNK/LUtMdr87w0ui1A=
AllowedIPs = 10.0.0.6/32

[Peer]
PublicKey = jtbY43ANRqFdOLDQAh6LhdmReyNmWBe1GG90KX58ZFI=
AllowedIPs = 10.0.0.7/32

[Peer]
PublicKey = 5xeRyWrwms51tCeF2xg6X5SNx1C+w6XLRDm/RrMmDCM=
AllowedIPs = 10.0.0.8/32

[Peer]
PublicKey = +zmQM3UG/FTsNPeK+dr/Np1wgryS6FYPRH4inwpfeVg=
AllowedIPs = 10.0.0.9/32

[Peer]
PublicKey = EcfnigI84zio1VVQA2zCF248jGKY6UMZIxT0oy/DK2M=
AllowedIPs = 10.0.0.10/32

[Peer]
PublicKey = BL4iQy3XOGEV2nFBnErB+rEEOImdUuTKa+QUCKwOUy0=
AllowedIPs = 10.0.0.11/32


##################################server_eof################################




###################################client###################################

## test worked client


[Interface]
#Address = 10.0.0.2/24
ListenPort = 9955
PrivateKey = +C4uxCTty8Ut+xmPbxTRdfgJS0N9MMbmBp1TxTQ1UFs=

[Peer]
PublicKey = kUY1wkH5/s36E40aCqpIGD66IjCC+pdPcmp+CouTwwc=
AllowedIPs = 0.0.0.0/0
Endpoint = 192.168.93.1:9955




ip link add dev wg0 type wireguard
#
ip address add dev wg0 10.0.0.2/24
ip link set up dev wg0



############################################################################



#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#
# SSH, WG & iptables config script here.
# Init scripts names: S98wireguard
#
#


# test
echo "6MRVGgnT2YVwA1cB3vQClh3M7yHqxjEleUmT5j7ZL3M=" > /tmp/private111wg2.key
#
SSHD_PRIVKEY="09543nugpnhpug"
#
WG_PRIVKEY="/tmp/private111wg2.key"
WG_ALLOWED_IPS_PREFIX="10.0.0." #last octet gets appened
WG_ALLOWED_PEERS='aTJL7PyAj8qZeVXzOeU/vK7uaZz/5c9WWKWjoiVhFxE=,2,BLJoIJvKWLzHMG9XqN/DVC5Ebd/4ETDDtBHCbBaQuV4=,3,jX+rhNw7MGM69mz0OqPR4G4xXPRUkKyCRAN+E/Yr800=,4,pp/6s73O5SoO80p8qxrDIbVU8TNK/LUtMdr87w0ui1A=,6'
#WG_ALLOWED_PEER=""
WG_LISTEN_PORT="9955"

#
IPTBL_ALLOWED_INTERFACES="eth0,eth1,tun0"
#wg set wg2 listen-port 9955 private-key /tmp/private111wg2.key peer "/adUYOskAITkevdEKaBWWJFGgoatMrZJ06uHaWOPCRc=" allowed-ips 10.8.8.8/24
#

# configure network interface
ip link add dev wg0 type wireguard
#
ip address add dev wg0 10.0.0.1/24
ip link set up dev wg0

# set base WG settings
wg set wg0 listen-port $WG_LISTEN_PORT private-key $WG_PRIVKEY

IFS=","
# configure wireguard
let COUNTERR=0
TEMMPP_0=""
TEMMPP_1=""
for i in $WG_ALLOWED_PEERS; do
    #IFS=","
    echo i=$i
    # Hardcoded cidr for now.
    # comma separated digits in WG_ALLOWED_PEERS its last IP octet digits (xxx.xxx.xxx.2-254).
    # We just concatenate /32 with it.
    if [ ${#i} -ge 4 ] # ${#i} =  String Length, if len more than 4 its obvious key otherwise cidr :)
    then
         #cidrr=""
         #prefixx=""
         # keep peer PUBKEY
         TEMMPP_0=$i
    else
         #cidrr="/24"
         #prefixx=$WG_ALLOWED_IPS_PREFIX
         # keep peer allowed ip
         TEMMPP_1=$WG_ALLOWED_IPS_PREFIX$i"/32"
    fi
    if [ "${TEMMPP_0}" != "" ] && [ "${TEMMPP_1}" != "" ]; then
    /usr/bin/wg set wg0 peer "$TEMMPP_0" allowed-ips "$TEMMPP_1"
    TEMMPP_0=""
    TEMMPP_1=""
    fi
    let COUNTERR++
done


##################################################################################
#
#
#

# IFS=$','
# let numParam=0
# while IFS="," read -r PEERR
# do
#    eval WGPEERRPARAMS$numParam=$PEERR
#    #debug
#    echo WGPEERRPARAMS$numParam

#    let numParam++
# done <<-END
# $(for i in $WG_ALLOWED_IPS_SUFFIX; do printf "$i\n"; done)
# END
# #count lines
# IFS=$'\n'

