#!/usr/bin/env bash


# test / not used



# Block Torrent algo string using Boyer-Moore (bm)
iptables -I FORWARD 1 -m string --algo bm --string "BitTorrent" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "peer_id=" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string ".torrent" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "torrent" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "announce" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "info_hash" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string "/default.ida?" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string ".exe?/c+dir" -j DROP
iptables -I FORWARD 1 -m string --algo bm --string ".exe?/c_tftp" -j DROP

# Block Torrent keys
iptables -I FORWARD 1 -m string --algo kmp --string "peer_id" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "BitTorrent" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "BitTorrent protocol" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "bittorrent-announce" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "announce.php?passkey=" -j DROP

# Block Distributed Hash Table (DHT) keywords
iptables -I FORWARD 1 -m string --algo kmp --string "find_node" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "info_hash" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "get_peers" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "announce" -j DROP
iptables -I FORWARD 1 -m string --algo kmp --string "announce_peers" -j DROP

