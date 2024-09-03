### Task Idea

Re, Medium

This is supposed to based on anti-debug (pl. "nanomity") technique.
There are two programs attached: crackme and supervisor.
Crackme's .text is partialy encrypted and has inserted breakpoins.
In order to run the software one needs to run the supervisor which PTRACE the crackme
which makes it unable to attach any other soft.
Supervisor decrypts parts of the crackme during runtime.
I always wanted to implement it, so jctf2020 might be a chance.

Btw, it would be evil to sneak the flag somewhere in the supervisor xdd






How to compile:
make clean
make
python3 crypto_utility.py encrypt_crackme

#Now copy displayed code and paste to supervisor.c
make #again
#yay!
