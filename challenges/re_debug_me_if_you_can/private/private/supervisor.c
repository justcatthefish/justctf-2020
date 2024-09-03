#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <signal.h>
#include <syscall.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/reg.h>
#include <sys/user.h>
#include <unistd.h>
#include <errno.h>

#include <stdint.h>

long supervisor_data[] = {0x7777,0x707,0xaabb,0x202,0xabcd,0x101};

typedef struct {
    int id;
    long id_addr;
    long code_start;
    long code_end;
} Function;

typedef struct {
    uint64_t id;
    int offset_from_id_to_code;
    int offset_in_code;
    int len;
    uint64_t privkey;
    int encrypt_counter;
} Enc;

#define MAX_FUNCTIONS 100
Function functions[MAX_FUNCTIONS];
int f_ctr = 0;


#define MAX_ENCS 35
Enc encs[MAX_ENCS];

void fill_encs() {
	encs[0]=(Enc){.id=0x7777, .offset_from_id_to_code=0x18, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[1]=(Enc){.id=0x7777, .offset_from_id_to_code=0x18, .offset_in_code=0x70, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[2]=(Enc){.id=0x7777, .offset_from_id_to_code=0x18, .offset_in_code=0xdb, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[3]=(Enc){.id=0x7777, .offset_from_id_to_code=0x18, .offset_in_code=0x3b, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[4]=(Enc){.id=0x7777, .offset_from_id_to_code=0x18, .offset_in_code=0xa3, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[5]=(Enc){.id=0x707, .offset_from_id_to_code=0x14, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[6]=(Enc){.id=0x707, .offset_from_id_to_code=0x14, .offset_in_code=0x8, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[7]=(Enc){.id=0x707, .offset_from_id_to_code=0x14, .offset_in_code=0xb, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[8]=(Enc){.id=0x707, .offset_from_id_to_code=0x14, .offset_in_code=0x7, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[9]=(Enc){.id=0x707, .offset_from_id_to_code=0x14, .offset_in_code=0x7, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[10]=(Enc){.id=0xaabb, .offset_from_id_to_code=0x14, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[11]=(Enc){.id=0xaabb, .offset_from_id_to_code=0x14, .offset_in_code=0xb, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[12]=(Enc){.id=0xaabb, .offset_from_id_to_code=0x14, .offset_in_code=0x12, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[13]=(Enc){.id=0xaabb, .offset_from_id_to_code=0x14, .offset_in_code=0x8, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[14]=(Enc){.id=0xaabb, .offset_from_id_to_code=0x14, .offset_in_code=0xc, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[15]=(Enc){.id=0x202, .offset_from_id_to_code=0x18, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[16]=(Enc){.id=0x202, .offset_from_id_to_code=0x18, .offset_in_code=0x90, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[17]=(Enc){.id=0x202, .offset_from_id_to_code=0x18, .offset_in_code=0x11b, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[18]=(Enc){.id=0x202, .offset_from_id_to_code=0x18, .offset_in_code=0x4b, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[19]=(Enc){.id=0x202, .offset_from_id_to_code=0x18, .offset_in_code=0xd3, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[20]=(Enc){.id=0xabcd, .offset_from_id_to_code=0x18, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[21]=(Enc){.id=0xabcd, .offset_from_id_to_code=0x18, .offset_in_code=0x90, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[22]=(Enc){.id=0xabcd, .offset_from_id_to_code=0x18, .offset_in_code=0x11c, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[23]=(Enc){.id=0xabcd, .offset_from_id_to_code=0x18, .offset_in_code=0x4b, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[24]=(Enc){.id=0xabcd, .offset_from_id_to_code=0x18, .offset_in_code=0xd3, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[25]=(Enc){.id=0x1234, .offset_from_id_to_code=0x18, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[26]=(Enc){.id=0x1234, .offset_from_id_to_code=0x18, .offset_in_code=0x77, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[27]=(Enc){.id=0x1234, .offset_from_id_to_code=0x18, .offset_in_code=0xe9, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[28]=(Enc){.id=0x1234, .offset_from_id_to_code=0x18, .offset_in_code=0x3e, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[29]=(Enc){.id=0x1234, .offset_from_id_to_code=0x18, .offset_in_code=0xad, .len=8, .privkey=0x94, .encrypt_counter=0 };
	encs[30]=(Enc){.id=0x301, .offset_from_id_to_code=0x18, .offset_in_code=0x7, .len=8, .privkey=0x41, .encrypt_counter=0 };
	encs[31]=(Enc){.id=0x301, .offset_from_id_to_code=0x18, .offset_in_code=0x78, .len=8, .privkey=0x42, .encrypt_counter=0 };
	encs[32]=(Enc){.id=0x301, .offset_from_id_to_code=0x18, .offset_in_code=0xec, .len=8, .privkey=0x43, .encrypt_counter=0 };
	encs[33]=(Enc){.id=0x301, .offset_from_id_to_code=0x18, .offset_in_code=0x3f, .len=8, .privkey=0x27, .encrypt_counter=0 };
	encs[34]=(Enc){.id=0x301, .offset_from_id_to_code=0x18, .offset_in_code=0xaf, .len=8, .privkey=0x94, .encrypt_counter=0 };    
}

void procmsg(const char* format, ...) {
    va_list ap;
    fprintf(stdout, "[%d] ", getpid());
    va_start(ap, format);
    vfprintf(stdout, format, ap);
    va_end(ap);
}

long get_child_eip(pid_t pid) {
    struct user_regs_struct regs;
    ptrace(PTRACE_GETREGS, pid, 0, &regs);
    return regs.rip;
}

void set_child_rip(pid_t pid, long rip) {
    struct user_regs_struct regs;
    ptrace(PTRACE_GETREGS, pid, 0, &regs);
    regs.rip = rip;
    ptrace(PTRACE_SETREGS, pid, NULL, &regs);
}

long find_tag(pid_t pid, uint64_t from_addr, uint64_t tag) {
    for (uint64_t addr = from_addr; ; ++addr) {
        long word = ptrace(PTRACE_PEEKTEXT, pid, (void*) addr, 0);
        
        if ((uint32_t)word == tag) {
            return addr;
        }
    }
}

void dump_process_memory(pid_t pid, uint64_t from_addr)
{
    //procmsg("Dump of %d's memory from %p\n", pid, from_addr);
    int i = 0;
    for (uint64_t addr = from_addr; ; ++addr) {
        long word = ptrace(PTRACE_PEEKTEXT, pid, (void*) addr, 0);
        //printf("  %p:  %02lx\n", (void*) addr, word & 0xFF);
        i++;
        if(i==5)
            break;
    }
}

void patchcode_dec(pid_t pid, Enc e, Function f) {
    long addr = f.id_addr+e.offset_from_id_to_code+e.offset_in_code;
    uint64_t enc = ptrace(PTRACE_PEEKTEXT, pid, (void*) addr, 0);
    uint64_t patch = enc;

    uint64_t id = (e.id + e.encrypt_counter) & 0xffff;

    uint64_t id0 = id & 0xff;
    uint64_t id1 = (id & 0xff00) >> 8;
    id0 ^= (e.privkey & 0xff);
    id1 ^= (e.privkey & 0xff);
    patch ^= id0;
    patch ^= (id1 << 8);
    patch ^= (id0 << 16);
    patch ^= (id1 << 24);
    patch ^= (id0 << 32);
    patch ^= (id1 << 40);
    patch ^= (id0 << 48);
    patch ^= (id1 << 56);

    int x = ptrace(PTRACE_POKETEXT, pid, addr, patch);
}

void patchcode_enc(pid_t pid, Enc* e, Function f) {
    e->encrypt_counter += 7;
    
    long addr = f.id_addr+e->offset_from_id_to_code+e->offset_in_code;
    uint64_t enc = ptrace(PTRACE_PEEKTEXT, pid, (void*) addr, 0);
    uint64_t patch = enc;

    uint64_t id = (e->id + e->encrypt_counter) & 0xffff;
    uint64_t id0 = id & 0xff;
    uint64_t id1 = (id & 0xff00) >> 8;
    id0 ^= (e->privkey & 0xff);
    id1 ^= (e->privkey & 0xff);
    patch ^= id0;
    patch ^= (id1 << 8);
    patch ^= (id0 << 16);
    patch ^= (id1 << 24);
    patch ^= (id0 << 32);
    patch ^= (id1 << 40);
    patch ^= (id0 << 48);
    patch ^= (id1 << 56);

    int x = ptrace(PTRACE_POKETEXT, pid, addr, patch);
}

void run_debugger(pid_t child_pid) {
    int wait_status;
    unsigned icounter = 0;
    wait(0);
    //procmsg("debugger started\n");

    //procmsg("[init] child now at EIP = %p\n", get_child_eip(child_pid));

    ptrace(PTRACE_CONT, child_pid, 0, 0);
    wait(0);

    while(1) {
        long eip=get_child_eip(child_pid);

        uint32_t next = ptrace(PTRACE_PEEKTEXT, child_pid, (void*) eip, 0);
        if(next == 0x1337babe) {
            long id_addr = eip+4;
            uint16_t id = ptrace(PTRACE_PEEKTEXT, child_pid, (void*) id_addr, 0);

            int is_new=1;
            Function f;
            for(int i = 0; i < MAX_FUNCTIONS; i++) {
                if(functions[i].id == id) {
                    f = functions[i];
                    is_new = 0;
                    break;
                }
            }
            if(is_new) {
                f.id = id;
                f.id_addr = id_addr;
                f.code_start = find_tag(child_pid, eip, 0xfeedc0de)+4;
                f.code_end   = find_tag(child_pid, eip, 0xdeadc0de);
                functions[f_ctr++] = f;
            }

            for(int i = 0; i < MAX_ENCS; i++) {
                if(encs[i].id == id) {
                    patchcode_dec(child_pid, encs[i], f);
                }
            }

            set_child_rip(child_pid, f.code_start);
            ptrace(PTRACE_CONT, child_pid, NULL, NULL);
            wait(0);
        }
        else if(next == 0xdeadc0de) {
            for(int i = 0; i < MAX_FUNCTIONS; i++) {
                if(functions[i].code_end == eip) {
                    for(int j = 0; j < MAX_ENCS; j++) {
                        if(encs[j].id == functions[i].id) {
                            patchcode_enc(child_pid, &encs[j], functions[i]);
                        }
                    }

                    break;
                }
            }
            set_child_rip(child_pid, eip+4);
            ptrace(PTRACE_CONT, child_pid, NULL, NULL);
            wait(0);
        }
        else {
            perror("0xCCya!\n");
            ptrace(PTRACE_DETACH, child_pid, NULL, NULL);
            return;
        }

    }
}


void run_target(const char* programname) {
    //procmsg("target started. will run '%s'\n", programname);

    if (ptrace(PTRACE_TRACEME, 0, 0, 0) < 0) {
        //perror("ptrace");
        return;
    }
    execl(programname, programname, 0);
}


int main(int argc, char** argv) {
    fill_encs();

    pid_t child_pid;

    child_pid = fork();
    if (child_pid == 0)
        run_target("./crackme.enc");
    else if (child_pid > 0){
        run_debugger(child_pid);
    }
    else {
        //perror("fork");
        return -1;
    }

    return 0;
}
