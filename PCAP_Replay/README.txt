The hosts in the diagram are only allowed to talk to each other.

Host 172.16.88.50 is running Debian 9. It's MAC address for eth0 is 00:50:56:91:13:cd
This is considered the Inside host where we will replay malicious PCAP and safely direct it through the router to the Outside (Fake Internet) host.

Install prerequisite package - apt-get install arptables tcpdump
Install tcpreplay 4.3.1 https://tcpreplay.appneta.com/wiki/installation.html

Host 172.16.99.50 is running Debian 9. It's MAC address for eth0 is 00:50:56:91:80:dd
This is considered the Outside host acting as the fake internet.

Inetsim runs fake services like DNS, HTTP. Install Inetsim on the Outside host: https://www.inetsim.org/packages.html

The router between the two hosts is a CSR1000V running 16.12.1d.0.32 and UTD engine 1.0.8_SV2.9.13.0_XE16.12
172.16.88.50 is connected to Gig4 which has an IP address of 172.16.88.1 and a MAC address of 00:50:56:91:05:95
172.16.99.50 is connected to Gig5 which has an IP address of 172.16.99.1 and a MAC address of 00:50:56:91:23:e2

Your values for source and destination IP and MAC address will differ. Modify appropriately.

How to

1. Gather some malicious PCAP samples. There are several here: https://www.netresec.com/?page=PcapFiles

2. Run the isolation_inside.sh script on the Inside host.

3. Run the isolation_outside.sh script on the Outside host.

4. Change to a directory on the Inside host with a malicious PCAP sample. Rename the sample test.pcap.

5. Run the replay.sh script on the Inside host.

6. View activity on the Outside host with 'tcpdump -nnAi eth0 net 172.16.0.0/16'

7. Observe Snort alerts on the router via 'show utd engine standard logging events'



The isolation script works as follows:
#kill any dhcp services
killall dhclient

#Set the IP for eth0 to match our environment
ifconfig eth0 172.16.88.50 netmask 255.255.255.0

#Add a default gateway of the IP of the router connected to the subnet of the inside host
route add default gw 172.16.88.1

#Set the nameserver to the Outside (Fake Internet) host
echo "nameserver 172.16.99.50" > /etc/resolv.conf

#Clear IP tables and create rules to only allow the two hosts over layer 3.
iptables --flush
iptables -A INPUT -s 172.16.99.50 -j ACCEPT
iptables -A OUTPUT -d 172.16.99.50 -j ACCEPT
#iptables -A INPUT -s 172.16.88.1 -j ACCEPT
#iptables -A OUTPUT -d 172.16.88.1 -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP

#Clear arp tables and only allow the MAC address of the router.
arptables --flush
arptables -A INPUT --source-mac 00:50:56:91:05:95 -j ACCEPT



The replay script works as follows:

#Cache the pcap file
tcpprep --port --pcap=test.pcap --cachefile=in.cache

#Rewrite the source and destination IPs to match our environment.
tcprewrite --cachefile=in.cache --endpoints 172.16.88.50:172.16.99.50 --infile=test.pcap --outfile=out.pcap

#Rewrite the source and destination MAC addresses to direct these packets to the router.
tcprewrite --enet-smac=00:50:56:91:13:cd --enet-dmac=00:50:56:91:05:95 --infile=out.pcap --outfile=out2.pcap

#Replay the pcap out eth0 at 1Mbps 1 time.
/usr/local/bin/tcpreplay -i eth0 -K --mbps 1 --loop 1 out2.pcap
