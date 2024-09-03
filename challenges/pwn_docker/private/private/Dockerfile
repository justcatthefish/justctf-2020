FROM python:3.9

RUN apt-get update && apt-get install -y socat gpw jq

ENV DOCKERVERSION=18.03.1-ce
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

WORKDIR /task
COPY ./handle-user-connection.sh .
COPY ./chall.py .
COPY ./flag /flag
COPY ./clihashcash_amd64 .

CMD ["socat", "TCP-LISTEN:1337,fork", "exec:'/task/handle-user-connection.sh',pty"]
