### Pinata

The real target is an nginx server with a custom module.
It's sitting behing a proxy (also nginx) so teams can solve the challenge in isolation.
Please don't try to hack the proxy or abuse it, it's not part of the challenge.

The nginx worker process will be restarted if processing a reqest for longer than 1s.

The challenge is hosted in different locations on Digital Ocean.
In case you need lower latency you can create a Digital Ocean droplet in the same region.

Your sandbox will eventually expire (watch the timer), please write your exploits so they can survive that.

We intentionally do not provide the binary, look at the task name and let your imagination run :) Good luck!

* http://pinata-ams3.web.jctf.pro
* http://pinata-nyc3.web.jctf.pro
* http://pinata-sgp1.web.jctf.pro

Hints:
- It runs an amd64 Linux
