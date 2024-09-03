# justCTF [*] 2020

This repo contains sources for [justCTF [*] 2020](https://2020.justctf.team) challenges hosted by [justCatTheFish](https://ctftime.org/team/33893).

TLDR: Run a challenge with `./run.sh` (requires Docker/docker-compose and might require `sudo` as we use `nsjail` extensively under the hood).

The [`challenges/`](./challenges/) contains challanges directories with the following structure:
* `README.md` - official challenge description used during CTF
* `run.sh` - shell script to run the challenge locally (uses Docker and sometimes docker-compose)
* `public/` - files that were public/to download
* `private/` - sources and other unlisted files
* `flag.txt`/`metadata.json` - the flag (don't look there?)
* `solv/` - scripts and files with raw solution (used by healthcheck, if exists)
* other files


### Challenges

| Category | Name | Points | Solves |
|----------|------|--------|--------|
| web | [Baby CSP](./challenges/web_baby-csp) | 406 | 6 |
| web | [njs](./challenges/web_njs) | 394 | 7 |
| web | [Computeration Fixed](./challenges/web_computeration-fixed) | 333 | 14 |
| web | [Go-fs](./challenges/web_gofs) | 256 | 30 |
| web | [Computeration](./challenges/web_computeration) | 121 | 103 |
| re | [REmap](./challenges/re_REmap) | 383 | 8 |
| re | [Rusty](./challenges/re_rusty) | 363 | 10 |
| re | [ABNF: grammar is fun](./challenges/re_abnf-grammar-is-fun) | 283 | 23 |
| re | [debug_me_if_you_can](./challenges/re_debug_me_if_you_can) | 279 | 24 |
| re | [reklest](./challenges/re_reklest) | 164 | 70 |
| re | [That's not crypto](./challenges/re_thats-not-crypto) | 50 | 254 |
| pwn | [Pinata](./challenges/pwn_pinata) | 474 | 2 |
| pwn | [qmail](./challenges/pwn_qmail) | 363 | 10 |
| pwn, misc | [D0cker](./challenges/pwn_docker) | 231 | 38 |
| pwn, misc | [MyLittlePwny](./challenges/pwn_mylittlepwny) | 50 | 214 |
| misc, stegano, ppc | [Steganography 2.0](./challenges/stegano_steganography-20) | 500 | 0 |
| misc, web, re, pwn | [PainterHell](./challenges/misc_tf2) | 500 | 0 |
| misc | [The survey](None) | 500 | 0 |
| misc, web | [Forgotten name](./challenges/misc_forgotten-name) | 72 | 160 |
| misc | [Sanity Check](./challenges/misc_sanity-check) | 50 | 764 |
| fore, misc | [Remote Password Manager](./challenges/misc_remote-password-manager) | 347 | 12 |
| fore, misc | [PDF is broken, and so is this file](./challenges/misc_pdf) | 67 | 166 |
| crypto | [Oracles](./challenges/crypto_oracles) | 383 | 8 |
| crypto | [25519](./challenges/crypto_25519) | 199 | 51 |


### Write-ups
Write-ups can be found on [CTFTime](https://ctftime.org/event/1050/tasks/). You should also look at challenges solution directories, if they exist (`solv/`).

### CTF Platform
We wrote our own CTF platform which is available [here](https://github.com/justcatthefish/ctfplatform).

### justCTF [*] 2020 was sponsored by
* [Trail of Bits](https://www.trailofbits.com/)
* [Wirtualna Polska](https://www.wp.pl/)   
