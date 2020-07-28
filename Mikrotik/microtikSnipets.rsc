

# enable NTP and set UA ntp servs
#

/system ntp client
set enabled=yes primary-ntp=62.149.0.30 secondary-ntp=62.149.2.7 \
    server-dns-names=\
    ntp.time.in.ua,1.ua.pool.ntp.org,0.ua.pool.ntp.org,ntp3.time.in.ua

# blackhole BOGON nets
# https://ipgeolocation.io/resources/bogon.html

/ip route
add comment="BOGON" distance=249 dst-address=0.0.0.0/8 type=blackhole
add comment="BOGON" distance=249 dst-address=10.0.0.0/8 type=blackhole
add comment="BOGON" distance=249 dst-address=172.16.0.0/12 type=blackhole
add comment="BOGON" distance=249 dst-address=192.168.0.0/16 type=blackhole
add comment="BOGON" distance=249 dst-address=100.64.0.0/10 type=blackhole
add comment="BOGON" distance=249 dst-address=127.0.0.0/8 type=blackhole
add comment="BOGON" distance=249 dst-address=127.0.53.53 type=blackhole
add comment="BOGON" distance=249 dst-address=169.254.0.0/16 type=blackhole
add comment="BOGON" distance=249 dst-address=192.0.0.0/24 type=blackhole
add comment="BOGON" distance=249 dst-address=192.0.2.0/24 type=blackhole
add comment="BOGON" distance=249 dst-address=198.18.0.0/15 type=blackhole
add comment="BOGON" distance=249 dst-address=198.51.100.0/24 type=blackhole
add comment="BOGON" distance=249 dst-address=203.0.113.0/24 type=blackhole
add comment="BOGON" distance=249 dst-address=224.0.0.0/4 type=blackhole
add comment="BOGON" distance=249 dst-address=240.0.0.0/4 type=blackhole
add comment="BOGON" distance=249 dst-address=255.255.255.255/32 type=blackhole

#
