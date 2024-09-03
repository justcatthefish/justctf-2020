flag =    b'justCTF{just_a_rusty_old_DOS_stub_task}'
encoder = b'This program cannot be run in DOS mode.'

result = [x for x in flag]

crc_flag = sum(result) & 0xFFFF
crc_encoder = sum(encoder) & 0xFFFF 

for i,c in enumerate(encoder):
	for d in range(i,len(flag)):
		result[d] = result[d] ^ c
		

with open('flag.asm','w') as f:
	f.write('decrypted_flag db ')
	f.write(''.join([f'{c},' for c in result]))
	f.write("'$'\r\n")
	f.write(f'flag_crc dw {crc_flag}\r\n')
	f.write(f'encoder_crc dw {crc_encoder}\r\n')
	f.write(f'flag db {len(flag)} dup(0),\'$\'\r\n')
	f.write(f'l dw {len(flag)}')
