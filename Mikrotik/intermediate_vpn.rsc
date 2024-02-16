# RouterOS 7.11.2

# Router client 1
/interface wireguard add comment=TEST_VPN_R1 listen-port=13231 mtu=1420 name=TESTWG0
/interface wireguard peers add allowed-address=0.0.0.0/0 comment=TEST_VPN_R1 endpoint-address=192.168.10.108 endpoint-port=47815 interface=TESTWG0 persistent-keepalive=20s public-key="EdkzUuQdVx626cwuLz5KyHtNlfPzXq8gWgn+jjgzSzg="
/ip address add address=10.0.0.1/24 comment=TEST_VPN interface=TESTWG0 network=10.0.0.0
/ip route add comment=TEST_VPN disabled=no distance=1 dst-address=172.16.10.0/24 gateway=TESTWG0 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10

# Router client 2
/interface wireguard add comment=TEST_VPN_R2 listen-port=13231 mtu=1420 name=TESTWG0
/interface wireguard peers add allowed-address=0.0.0.0/0 comment=TEST_VPN_R2 endpoint-address=192.168.10.108 endpoint-port=47815 interface=TESTWG0 persistent-keepalive=20s public-key="EdkzUuQdVx626cwuLz5KyHtNlfPzXq8gWgn+jjgzSzg="
/ip address add address=10.0.0.2/24 interface=TESTWG0 network=10.0.0.0
/ip route add comment=TEST_VPN disabled=no distance=1 dst-address=192.168.200.0/24 gateway=TESTWG0 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10

# Router intermediate R3
/interface wireguard add comment=TEST_VPN listen-port=47815 mtu=1420 name=TESTWG0
/ip vrf add comment=TEST_VPN interfaces=TESTWG0 name=VRF2_TESTWG0
/interface wireguard peers add allowed-address=10.0.0.1/32,192.168.200.0/24 comment=TEST_VPN_R1 interface=TESTWG0 public-key="c6/uIw97aOXIuOy3MHQzQkZa/QH5TARD8AiP1WHPInc="
/interface wireguard peers add allowed-address=10.0.0.2/32,172.16.10.0/24 comment=TEST_VPN_R2 interface=TESTWG0 public-key="GaqnE952fulUoIroJ6N9m1FSpgcB1Z6hbjPiZZlTegk="
/ip address add address=10.0.0.3/24 comment=TEST_VPN interface=TESTWG0 network=10.0.0.0
/ip route add comment=TEST_VPN disabled=no distance=1 dst-address=192.168.200.0/24 gateway=TESTWG0@VRF2_TESTWG0 pref-src="" routing-table=VRF2_TESTWG0 scope=30 suppress-hw-offload=no target-scope=10 vrf-interface=TESTWG0
/ip route add comment=TEST_VPN disabled=no distance=1 dst-address=172.16.10.0/24 gateway=TESTWG0@VRF2_TESTWG0 pref-src="" routing-table=VRF2_TESTWG0 scope=30 suppress-hw-offload=no target-scope=10 vrf-interface=TESTWG0




# example

# sets up a network using WireGuard VPN technology with three routers: R1, R2, and an intermediate router R3.
# Each router has its WireGuard interface configured along with peer connections. 
# R1 and R2 are clients connecting to R3, which acts as a gateway.
# R3 manages communication between R1 and R2, allowing them to communicate with each other securely over the VPN network.
