#!/usr/bin/python
import re
import sys
import base64
import binascii

string = sys.argv[1]

# if encoded pcap is hex from sourcefire
if re.match(r"^[0-9a-fA-F]+$", string):
    print "\nall day I dream about hex\n"
    print binascii.unhexlify(string)

# if encoded pcap is base64 from suricata
elif re.match(r"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$", string):
    print "\nall your base64 are belong to us\n"
    print base64.b64decode(string)

# it's neither hex or base64
else:
    print "\nThat does not compute\n"
    exit()
