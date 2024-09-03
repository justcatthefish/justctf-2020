#!/usr/bin/python3

from Crypto import Random
from Crypto.Cipher import AES
import sys
import hashlib
import struct
import os
import random 

def pad(s):
    return s + b"\0" * (AES.block_size - len(s) % AES.block_size)

def encrypt(message, key, key_size=256):
    message = pad(message)
    iv = Random.new().read(AES.block_size)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    return iv + cipher.encrypt(message)

def decrypt(ciphertext, key):
    iv = ciphertext[:AES.block_size]
    cipher = AES.new(key, AES.MODE_CBC, iv)
    plaintext = cipher.decrypt(ciphertext[AES.block_size:])
    return plaintext.rstrip(b"\0")

def encrypt_file(file_name, key):
    with open(file_name, 'rb') as fo:
        plaintext = fo.read()
    enc = encrypt(plaintext, key)
    with open(file_name + ".enc", 'wb') as fo:
        fo.write(enc)

def decrypt_file(file_name, key):
    with open(file_name, 'rb') as fo:
        ciphertext = fo.read()
    dec = decrypt(ciphertext, key)
    with open(file_name[:-4] + ".dec", 'wb') as fo:
        fo.write(dec)


def xor_helper(target, id, key):
    ret = target
    for i in range(0, len(ret)):
        ret[i] = ret[i] ^ id[i % len(id)] ^ key
    return ret

def encrypt_crackme():
    enc_ctr=0
    with open("crackme.enc", 'wb') as fo:
        with open("crackme", 'rb') as f:
            text = f.read()
            text_cpy = bytearray(text)
            idx_start_tag = 0
            while idx_start_tag != -1:
                idx_start_tag = text.find(b"\xbe\xba\x37\x13", idx_start_tag+1)
                if idx_start_tag == -1:
                    break
                
                idx_id = idx_start_tag + 4
                id = struct.unpack('H', text[idx_id:idx_id+2])[0]

                idx_feedcode   = text.find(b"\xde\xc0\xed\xfe", idx_start_tag+1)
                idx_code_start = idx_feedcode + 4
                idx_end_tag    = text.find(b"\xde\xc0\xad\xde", idx_feedcode+1)
                code_len       = idx_end_tag-idx_code_start-1
                
                text_cpy[idx_id+2:idx_feedcode] = [0x90] * (idx_feedcode-(idx_id+2))
                
                code = bytearray(text[idx_code_start:idx_end_tag-1])

                idx1 = 7
                idx1_len = 8
                key1 = 0x41
                idx2 = int(len(code)/2 - 2)
                idx2_len = 8 
                key2 = 0x42
                idx3 = len(code) - 9
                idx3_len = 8
                key3 = 0x43

                idx4 = int(len(code)/4 + 2)
                idx4_len = 8
                key4 = 0x27

                idx5 = int(len(code)*0.75 - 8)
                idx5_len = 8
                key5 = 0x94

                id_bytes = text[idx_id:idx_id+2]
                code[idx1:idx1+idx1_len] = xor_helper(code[idx1:idx1+idx1_len], id_bytes, key1)
                code[idx2:idx2+idx2_len] = xor_helper(code[idx2:idx2+idx2_len], id_bytes, key2)
                code[idx3:idx3+idx3_len] = xor_helper(code[idx3:idx3+idx3_len], id_bytes, key3)
                
                code[idx4:idx4+idx4_len] = xor_helper(code[idx4:idx4+idx4_len], id_bytes, key4)
                code[idx5:idx5+idx5_len] = xor_helper(code[idx5:idx5+idx5_len], id_bytes, key5)

                print(f"encs[{enc_ctr}]=(Enc){'{'}.id={hex(id)}, .offset_from_id_to_code={hex(idx_code_start-idx_id)}, "
                    f".offset_in_code={hex(idx1)}, .len={idx1_len}, .privkey={hex(key1)}, .encrypt_counter=0 {'}'};")
                enc_ctr += 1
                print(f"encs[{enc_ctr}]=(Enc){'{'}.id={hex(id)}, .offset_from_id_to_code={hex(idx_code_start-idx_id)}, "
                    f".offset_in_code={hex(idx2)}, .len={idx2_len}, .privkey={hex(key2)}, .encrypt_counter=0 {'}'};")
                enc_ctr += 1
                print(f"encs[{enc_ctr}]=(Enc){'{'}.id={hex(id)}, .offset_from_id_to_code={hex(idx_code_start-idx_id)}, "
                    f".offset_in_code={hex(idx3)}, .len={idx3_len}, .privkey={hex(key3)}, .encrypt_counter=0 {'}'};")
                enc_ctr += 1

                print(f"encs[{enc_ctr}]=(Enc){'{'}.id={hex(id)}, .offset_from_id_to_code={hex(idx_code_start-idx_id)}, "
                    f".offset_in_code={hex(idx4)}, .len={idx4_len}, .privkey={hex(key4)}, .encrypt_counter=0 {'}'};")
                enc_ctr += 1
                print(f"encs[{enc_ctr}]=(Enc){'{'}.id={hex(id)}, .offset_from_id_to_code={hex(idx_code_start-idx_id)}, "
                    f".offset_in_code={hex(idx5)}, .len={idx5_len}, .privkey={hex(key5)}, .encrypt_counter=0 {'}'};")
                enc_ctr += 1

                #key=hashlib.md5(text[idx_id:idx_id+2]).hexdigest()

                #for i in range(0, code_len):
                #    code[i] = code[i] % ord(key[i % len(key)])

                text_cpy[idx_code_start:idx_end_tag-1] = code

            fo.write(text_cpy)
    os.system("chmod +x crackme.enc")


def gen_secret_key():
    upper_bound = 128
    enc = list(range(1,upper_bound))
    random.shuffle(enc)
    print(enc)

    secret=[]
    for i in range(1, upper_bound):
        idx=enc.index(i)
        tmp=[]
        while idx != 0:
            if(idx%2 == 0):
                tmp.append('1')
            else:
                tmp.append('0')
            idx = (idx-1)//2
           
        tmp.reverse()
        tmp.append('?')
        secret = secret + tmp
    print(''.join(secret))

if len(sys.argv) != 2:
    print("./crypto_utility.py encrypt_image/decryt_image/encrypt_crackme")
    sys.exit()
if sys.argv[1] == "encrypt_image":
    with open("secret_key", 'rb') as f:
        key = f.read()
        key = hashlib.md5(key).hexdigest()
        print(f"encoding with key {key}...")
        encrypt_file("flag.png", key)
elif sys.argv[1] == "decrypt_image":
    with open("secret_key", 'rb') as f:
        key = f.read()
        key = hashlib.md5(key).hexdigest()
        print(f"decoding with key {key}...")
        decrypt_file("flag.png.enc", key)
elif sys.argv[1] == "encrypt_crackme":
    encrypt_crackme()
elif sys.argv[1] == "keygen":
    gen_secret_key()
else:
    print("./crypto_utility.py e/d")
    sys.exit()