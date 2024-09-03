FROM disconnect3d/nsjail:2.9

RUN apt update && apt install -y libgmime-2.6-0 texinfo python3 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/erkin/ponysay && cd ponysay && python3 setup.py --freedom=partial install

RUN groupadd -g 99999 jailed && \
    useradd --uid 99999 --gid 99999 jailed && \
    mkdir /home/jailed && \
    chown jailed /home/jailed -R && \
    chmod 755 /home/jailed -R

RUN mkdir /task

# Copy files
COPY server.py /
COPY nsjail /
COPY nsjail.cfg /
COPY run_task.sh /
COPY null.py /null.py

ADD flag /task/flag

RUN chmod o+r /task/flag
RUN chmod +x /run_task.sh

RUN cp /usr/bin/od /bin/od

CMD /run_task.sh
