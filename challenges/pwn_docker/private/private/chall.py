import sys
import time
import random
import subprocess
import re
import string
import json

CONTAINER_ID_REGEX = '[a-z0-9]{64}'

def log(msg, *a):
    #print('[LOG] ' + msg, *a)
    pass

def inp():
    try:
        data = input().strip()
    except Exception as e:
        log(str(e))
        print("Failed to get input from you. Terminating!")
        sys.exit(1)
    return data


def random_str(length):
    # Random string with the combination of lower and upper case
    letters = string.ascii_letters
    result_str = ''.join(random.choice(letters) for i in range(length))
    log("Random string is:", result_str)
    return result_str


def get_container_overlayz_secret_path(container_id):
    CMD = ["docker", "inspect", "--", container_id]
    log("Inspecting %s" % CMD)
    out = subprocess.check_output(CMD)
    # jq '.[0]["GraphDriver"]["Data"]["UpperDir"]'
    data = json.loads(out)
    data = data[0]['GraphDriver']['Data']['UpperDir']
    id_diff_path = data[len('/var/lib/docker/overlay2/'):]
    host_path = '/var/lib/docker/overlay2/' + id_diff_path + '/secret'
    return host_path, '/overlayz/%s/secret' % id_diff_path

def constant_time_compare(val1, val2):
    if isinstance(val1, str): val1 = val1.encode()
    if isinstance(val2, str): val2 = val2.encode()

    if len(val1) != len(val2):
        return False
    result = 0
    for x, y in zip(val1, val2):
        result |= x ^ y
    return result == 0


def get_data():
    try:
        data = subprocess.check_output('ls -l /sys/kernel/slab/*/cgroup/', shell=True).decode().splitlines()
        cgroups = set(line.split('(')[-1][:-1].split(':')[1] for line in data if '(' in line and line[-1] == ')')

    except Exception as e:
        log(str(e))
        print("Oracle failure #1: this should never happen, please contact admins if this reappears.")
        sys.exit(1)

    #log('\n'.join(sorted(cgroups)))
    return cgroups

def get_my_container_id():
    try:
        with open('/proc/self/cgroup') as f:
            container_id = f.read().splitlines()[0].split('docker/')[1]
            return container_id
    except Exception as e:
        log(str(e))
        print("Oracle failure #2: this should never happen, please contact admins if this reappears.")
        sys.exit(1)
 

def main():
    cgrps = get_data()

    def filter_container_ids(iterable):
        return [
            i for i in iterable if re.match(CONTAINER_ID_REGEX, i)
        ]

    # get cpu
    cpuinfo_lines = open('/proc/cpuinfo').read().splitlines()
    cpumodel_line = next(line for line in cpuinfo_lines if 'model name' in line)
    cpumodel = cpumodel_line.split(': ')[1].strip()


    print("""Welcome to the
    ______ _____      _             
    |  _  \  _  |    | |            
    | | | | |/' | ___| | _____ _ __ 
    | | | |  /| |/ __| |/ / _ \ '__|
    | |/ /\ |_/ / (__|   <  __/ |   
    |___/  \___/ \___|_|\_\___|_|   
    oracle!""")

    print("I will give you the flag if you can tell me certain information about the host (:")
    print("ps: brute forcing is not the way to go.")


    print("Let's go!")

    print("[Level 1] What is the full *cpu model* model used?")
    log('My cpu model:', cpumodel)
    cpu_reply = inp()

    if cpu_reply != cpumodel:
        print("Unfortunately not, bye!")
        sys.exit(1)

    print("That was easy :)")

    print("[Level 2] What is your *container id*?")
    container_id = inp()

    if len(container_id) != 64:
        print("Container ids have a length of 64. Get lost...")
        sys.exit(1)

    if not re.match(CONTAINER_ID_REGEX, container_id):
        print("Wrong container format, I expect %s from you. Bye!" % CONTAINER_ID_REGEX)
        sys.exit(1)

    # We mount this properly in docker-compose

    try:
        HOST_PATH, SECRET_PATH = get_container_overlayz_secret_path(container_id) 
    except Exception as e:
        #print(e)
        print('This is not your container id! Bye!')
        sys.exit(1)

    written_secret = random_str(64)

    try:
        with open(SECRET_PATH, 'w') as f:
            f.write(written_secret)
    except Exception as e:
        log(str(e))
        print('This is not your container id! Bye!')
        sys.exit(1)

    print("[Level 3] Let me check if you truly given me your container id. I created a /secret file on your machine. What is the hidden secret?")

    secret = inp()
    if not constant_time_compare(written_secret, secret):
        print('Meh, that is not the secret I wrote into your /secret path. Goodbye.')
        sys.exit(1)

    print("[Level 4] Okay but... where did I actually write it? What is the path on the host that I wrote the /secret file to which then appeared in your container? (ps: there are multiple paths which you should be able to figure out but I only match one of them)")
    log("EXPECTED PATH:", HOST_PATH)
    path = inp()

    if not path.endswith('/secret'):
        print("Well, your path should end with /secret, eh? Terminating.")
        sys.exit(1)

    if not constant_time_compare(HOST_PATH, path):
        print("Incorrect path :(, Bye!")
        sys.exit(1)

    print("[Level 5] Good! Now, can you give me an id of any *other* running container?")
    other_container_id = inp()

    if other_container_id == container_id:
        print('I guess you did not understand the **other** part. Bye! :(')
        sys.exit(1)

    if len(other_container_id) != 64:
        print("Container ids have a length of 64. Get lost...")
        sys.exit(1)

    if not re.match(CONTAINER_ID_REGEX, other_container_id):
        print("Wrong container format, I expect %s from you. Bye!" % CONTAINER_ID_REGEX)
        sys.exit(1)

    all_container_ids = filter_container_ids(get_data())

    if other_container_id not in all_container_ids:
        print("I did not find this container id :(. Bye!")
        sys.exit(1)
        

    print("[Level 6] Now, let's go with the real and final challenge. I, the Docker Oracle, am also running in a container. What is my container id?")
    oracle_container_id = inp()

    if len(oracle_container_id) != 64:
        print("Container ids have a length of 64. Get lost...")
        sys.exit(1)

    if not re.match(CONTAINER_ID_REGEX, oracle_container_id):
        print("Wrong container format, I expect %s from you. Bye!" % CONTAINER_ID_REGEX)
        sys.exit(1)

    my_container_id = get_my_container_id()

    if not constant_time_compare(my_container_id, oracle_container_id):
        if oracle_container_id in (container_id, other_container_id):
            print("If you think you will trick me by passing me a container id I already saw again, you are wrong :D bye!")
            sys.exit(1)

        print("Wrong! This is not my container id :(")
        sys.exit(1)


    # WIN
    print("[Levels cleared] Well done! Here is your flag!")
    with open('/flag') as f:
        flag = f.read()
        print(flag)
        print("Good job o/")


try:
    main()
except Exception as e:
    log(str(e))
    print('---> Oracle failed with an exception. This should not happen. Please contact admins. <---')
    raise e
