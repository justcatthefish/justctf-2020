import sys
import subprocess
import re
from shlex import quote

sys.stderr = None

while True:
    print("> ", end='')
    sys.stdout.flush()
    cmd = sys.stdin.readline()
    if not cmd:
        continue
    blacklist= ['<', '-', '\'','$','(',')','>','&','%', '^', '*', '?', '[', ']', '{', '}', '=', '|', ';', '"', '\\', '.', '/', 'cat', 'less', 'more', 'head', 'tail', 'tac', 'vi', 'grep', 'sh', 'bash', 'ash', 'nc', 'perl', 'python', 'php', 'ruby', 'awk', 'netcat', 'sed', 'nano', 'curl', 'wget', 'GET', 'POST', 'rev', 'hint', 'secret']
    check = re.compile('|'.join(re.escape(b) for b in blacklist))
    if check.findall(cmd):
        cmd_old = cmd
        cmd = quote("I can't swear ;(")
        if any(b in cmd_old for b in ['cat']):
            cmd = quote('I like cats :)')
        if any(b in cmd_old for b in ['less', 'more']):
            cmd = quote('No less, no more!')
        if any(b in cmd_old for b in ['tail']):
            cmd = quote('I have a ponytail!')
        if any(b in cmd_old for b in ['head']):
            cmd = quote('My head is in the clouds :heart:')
        if any(b in cmd_old for b in ['vim', 'vi']):
            cmd = quote('You are fantastic but try harder!')
        if any(b in cmd_old for b in ['tac']):
            cmd = quote('I love Tacet :*')
        if any(b in cmd_old for b in ['grep', 'egrep', 'fgrep']):
            cmd = quote('Yay! I love grapes :yum:')
        if any(b in cmd_old for b in ['awk']):
            cmd = quote('This is so awkward...')
        if any(b in cmd_old for b in ['sed']):
            cmd = quote('You make me sad :(')
        if any(b in cmd_old for b in ['perl', 'python', 'python3', 'php', 'ruby']):
            cmd = quote('One day I will be a programmer!')
        if any(b in cmd_old for b in ['nc', 'netcat']):
            cmd = quote('I lost my way to home, help me find it :*')
        if any(b in cmd_old for b in ['curl']):
            cmd = quote('Look, I have curly hairs')
        if any(b in cmd_old for b in ['wget', 'GET']):
            cmd = quote('https://www.youtube.com/watch?v=P8JEm4d6Wu4')
        if any(b in cmd_old for b in ['rev']):
            cmd = quote('73313')
        if any(b in cmd_old for b in ['hint', 'secret']):
            cmd = quote('I am not hiding anything from you :)')
        if any(b in cmd_old for b in ['-']):
            cmd = quote('I don\'t want to argue')
        try:
            subprocess.call(b'/usr/bin/ponysay -- ' + cmd.encode(), stderr=None, timeout=1, shell=True)
        except:
            pass
    else:
        try:
            subprocess.call(b'/usr/bin/ponysay -- ' + cmd.encode(), stderr=None, timeout=1, shell=True)
        except:
            pass
