default: 
	gcc crackme.c -lcrypto -lssl -o crackme &&      \
	gcc supervisor.c -lcrypto -lssl -o supervisor
clean:
	rm -f *.o crackme supervisor flag_decoded.png crackme.enc