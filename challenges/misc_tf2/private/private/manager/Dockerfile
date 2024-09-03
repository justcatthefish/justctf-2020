# build bot
FROM golang:1.13.4-stretch as builder_manager
WORKDIR /code/
COPY manager .
RUN go build -v ./cmd/main/

FROM ubuntu:18.04
RUN apt-get update -y && apt-get install -y wget curl unzip gnupg

# install docker client only
ENV DOCKERVERSION=18.03.1-ce
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

RUN curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# add user
RUN groupadd -g 99999 justctf && \
    useradd --uid 99999 --gid 99999 justctf && \
    mkdir /home/justctf && \
    chown justctf /home/justctf -R && \
    chmod 755 /home/justctf -R

WORKDIR /home/justctf/
USER justctf
COPY --from=builder_manager /code/main manager

# scripts
USER root
COPY scripts /scripts
RUN chmod +x /scripts/create.sh && \
    chmod +x /scripts/destory.sh && \
    chmod +x /scripts/run.sh
CMD ["/scripts/run.sh"]