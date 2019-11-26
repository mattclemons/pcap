#!/bin/bash
tcpprep --port --pcap=test.pcap --cachefile=in.cache

tcprewrite --cachefile=in.cache --endpoints 172.16.88.50:172.16.99.50 --infile=test.pcap --outfile=out.pcap

tcprewrite --enet-smac=00:50:56:91:13:cd --enet-dmac=00:50:56:91:05:95 --infile=out.pcap --outfile=out2.pcap

/usr/local/bin/tcpreplay -i eth0 -K --mbps 1 --loop 1 out2.pcap
