#!/use/bin/env sage -python
# -*- coding: utf8 -*-

from sage.all import *
from hashlib import sha256
from sys import exit
from pwn import *
import typer

app = typer.Typer()


ec = EllipticCurve(GF(2**255-19), [0,486662,0,1,0])
p = ec.order()
ZmodP = Zmod(p)
G = ec.lift_x(Integer(9))

ha = lambda x: x if isinstance(x, int) or isinstance(x, Integer) else product(x.xy())
hashs = lambda *x: int.from_bytes(sha256(b'.'.join([b'%X' % ha(x) for x in x])).digest(), 'little') % p


def hashp(x):
    x = hashs((x))
    while True:
        try:
            return ec.lift_x(x)
        except:
            x = hashs((x))


def sign(x, P, m):
    I = x * hashp(P)
    k = randint(1, p-1)
    e = hashs(m, k*G, k*hashp(P))
    s = (k - e*x) % p
    return (I, e, s)


counter = 0
def send_sign(conn, signature):
    global counter
    I, e, s = signature

    conn.recvuntil('I (x): ')
    conn.sendline(str(I.xy()[0]))
    conn.recvuntil('I (y): ')
    conn.sendline(str(I.xy()[1]))
    conn.recvuntil('e: ')
    conn.sendline(str(e))
    conn.recvuntil('s: ')
    conn.sendline(str(s))
    result = conn.recvline()

    if b'ok' not in result:
        print('error: ', result)
        exit(1)
    else:
        print('ok', counter)
        counter += 1


@app.command()
def main(ip: str, port: int):
    conn = remote(ip, port)
    x, Px, _, Py, _, _, m = conn.recvline().split()
    x = int(x); Px = int(Px[1:]); Py = int(Py); m = int(m)
    P = ec((Px, Py))

    I, e, s = sign(x, P, m)
    send_sign(conn, (I, e, s))
    spent = set([I])

    for _ in range(7):
        I2 = None
        while I2 is None or I2 in spent:
            L =  (p//random.choice((2,4,8))) * ec.random_point()
            o = L.order()
            while e % o != 0:
                I, e, s = sign(x, P, m)
            I2 = I + L
        assert e*I2 == e*I
        send_sign(conn, (I2, e, s))
        spent.add(I2)

    conn.interactive()
    conn.close()


if __name__ == "__main__":
    app()
