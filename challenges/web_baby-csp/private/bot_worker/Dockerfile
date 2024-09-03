# build bot
FROM golang:1.13.4-stretch as builder_manager
WORKDIR /code/
COPY bot .
RUN go build -v ./cmd/main/

FROM ubuntu:18.04
RUN apt-get update -y && apt-get install -y wget curl unzip gnupg

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -  && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get -y update && \
    apt-get install -y google-chrome-stable

# install chromedriver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip && \
        unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

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
CMD ["./manager"]
