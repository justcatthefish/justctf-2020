#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <openssl/md5.h>
#include <openssl/aes.h>

#define intro(IDX)                                 \
    __asm__ volatile ("int3");                     \
    __asm__ volatile (".long 0x1337babe");         \
    __asm__ volatile (".short %p0" :: "i" (IDX));  \
    volatile int x = 1;                            \
    if (x == 0) goto iwannadeadc0de;               \
    __asm__ volatile (".long 0xfeedc0de");         \
    

#define outro                                      \
    iwannadeadc0de:                                \
    __asm__ volatile ("int3");                     \
     __asm__ volatile (".long 0xdeadc0de");        \

uint8_t pw[] = {27, 89, 41, 76, 61, 111, 34, 127, 38, 28, 44, 47, 7, 78, 23, 30, 97, 10, 83, 16, 52, 101, 74, 66, 88, 8, 29, 96, 51, 85, 55, 68, 82, 57, 46, 114, 15, 110, 126, 63, 50, 71, 90, 19, 25, 6, 122, 81, 24, 26, 99, 72, 2, 119, 62, 84, 53, 22, 4, 94, 79, 73, 48, 3, 21, 113, 77, 17, 56, 18, 5, 69, 39, 104, 58, 117, 9, 32, 1, 64, 105, 35, 106, 59, 65, 95, 123, 87, 60, 31, 102, 86, 92, 12, 54, 115, 45, 103, 67, 93, 75, 40, 118, 120, 125, 49, 109, 37, 20, 116, 91, 107, 13, 80, 112, 100, 14, 98, 43, 11, 70, 42, 124, 121, 108, 36, 33};

char *str2md5(const char *str, int length) {
    intro (0x7777)
    
    int n;
    MD5_CTX c;
    unsigned char digest[16];
    char *out = (char*)malloc(33);
    MD5_Init(&c);
    while (length > 0) {
        if (length > 512) {
            MD5_Update(&c, str, 512);
        } else {
            MD5_Update(&c, str, length);
        }
        length -= 512;
        str += 512;
    }
    MD5_Final(digest, &c);
    for (n = 0; n < 16; ++n)
        snprintf(&(out[n*2]), 16*2, "%02x", (unsigned int)digest[n]);

    return out;

    outro
}

//the more functions the better...

int mult_add(int num, int mult, int add) {
    intro(0x0707);
    const int res = num*mult+add;
    outro
    return res;
}

int check_chr(char c1, char c2) {
    intro(0xaabb);
    int retval = (c1 == c2) ? 1 : -1;
    outro
    return retval;
}

int check(char* buffer, uint64_t len) {
    intro(0x0202)
    int res=1; 
    int buffer_idx = 0;
    for(int i = 1; i <= sizeof(pw); i++) {
        int pw_idx = 0;
        while(1) {
            if (buffer_idx >= len){
                res = -1;
                break;
            }
            char c = buffer[buffer_idx++];
            if(check_chr(c, '0') == 1) {
                pw_idx = mult_add(pw_idx, 2, 1);
            }
            else if (check_chr(c, '1') == 1) {
                pw_idx = mult_add(pw_idx, 2, 2);
            }
            else if (check_chr(c, '?') == 1) {
                if (pw[pw_idx] == i)
                    break;
                else {
                    res = -1;
                    break;
                }
            }
            else {
                res = -1;
                break;
            }
        }
        if(res == -1)
            break;
    }
    if (buffer_idx +1 != len)
        res = -1;
    outro
    return res;
}

void decrypt(char* img_buffer, uint64_t img_len,
                char* key, long int keylen) {
    intro(0xabcd)

    unsigned char iv[AES_BLOCK_SIZE];
    for(int i = 0; i < 16; i++)
        iv[i] = img_buffer[i];

    unsigned char* dec_out = malloc(img_len);

    AES_KEY dec_key;
    AES_set_decrypt_key(key, keylen*8, &dec_key);
    AES_cbc_encrypt(img_buffer+16, dec_out, img_len-16,
                      &dec_key, iv, AES_DECRYPT);

    FILE* fp = fopen("flag_decoded.png", "wb");
    if(fp == NULL) {
        printf("Error! https://www.youtube.com/watch?v=Khk6SEQ-K-k\n");
        exit(1);
    }

    fwrite(dec_out, 1, img_len-16, fp);
    fclose(fp);

    printf("Decoding done!\n"
           "Check out flag_decoded.png\n");
    free(dec_out);
    outro
}

int readFile(char* filename, char** buffer, long int* len) {
    intro(0x1234)
    
    FILE *file = fopen(filename, "rb");

	if (!file) {
		printf("Error! https://www.youtube.com/watch?v=Khk6SEQ-K-k\n");
		return -1;
	}
	fseek(file, 0, SEEK_END);
	*len = ftell(file);
	fseek(file, 0, SEEK_SET);
	*buffer = (char *)malloc(*len+1);
	if (!(*buffer)) {
		printf("Error! https://www.youtube.com/watch?v=Khk6SEQ-K-k\n");
        fclose(file);
		return -1;
	}

	fread(*buffer, *len, 1, file);
	fclose(file);

    outro
}

int main(int argc, char* argv[]) {
    intro(0x0301)

    printf("Hello there!\n");
    long int len=0;
    char* buffer;
    if (readFile("secret_key", &buffer, &len) == -1)
        return -1;
    
    int res = check(buffer, len);
    if (res == -1) {
		printf("Wrong password! https://www.youtube.com/watch?v=Khk6SEQ-K-k\n");
        free(buffer);
        return -1;
    }

    char* md5str = str2md5 (buffer, len);
    
    long int img_len=0;
    char* img_buffer;
    if (readFile("flag.png.enc", &img_buffer, &img_len) == -1)
        return -1;

    decrypt (img_buffer, img_len, md5str, 32);

    free (md5str);
    free(img_buffer);

    outro
}