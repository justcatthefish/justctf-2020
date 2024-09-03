#FROM ubuntu:18.04
FROM disconnect3d/nsjail:2.9

RUN apt update && apt install -y libgmime-2.6-0 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 99999 jailed && \
    useradd --uid 99999 --gid 99999 jailed && \
    mkdir /home/jailed && \
    chown jailed /home/jailed -R && \
    chmod 755 /home/jailed -R

RUN mkdir /task

# Copy files
COPY qmail /task/
COPY nsjail /
COPY nsjail.cfg /
COPY run_task.sh /

ADD flag.txt /flag.txt

# For debugging
#RUN apt-get update && \
#    apt-get install -y gdb python git python-pip && \
#    pip install pwntools && \
#    git clone https://github.com/pwndbg/pwndbg /pwndbg && \
#    cd /pwndbg && ./setup.sh

CMD /run_task.sh
