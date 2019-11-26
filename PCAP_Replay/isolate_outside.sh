#!/bin/bash
killall dhclient
ifconfig eth0 172.16.99.50 netmask 255.255.255.0
route add default gw 172.16.99.1
echo "nameserver 172.16.99.50" > /etc/resolv.conf

iptables --flush
iptables -A INPUT -s 172.16.88.50 -j ACCEPT
iptables -A OUTPUT -d 172.16.88.50 -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP

arptables --flush
arptables -A INPUT --source-mac 00:50:56:91:23:e2 -j ACCEPT
