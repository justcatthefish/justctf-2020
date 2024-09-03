FROM i386/ubuntu:16.04

RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install libstdc++6 libcurl3-gnutls wget libncurses5 bzip2 unzip tmux netcat

ENV USER tf2
ENV HOME /home/$USER
ENV SERVER /home/$USER/hlserver

RUN useradd $USER && mkdir -p $SERVER && chown -Rf $USER:$USER $SERVER

USER $USER

# install server
WORKDIR $SERVER
RUN wget -O - http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C . -xvz
ADD clean.sh update.sh tf2_ds.txt ./
RUN ./update.sh && ./clean.sh

CMD ["bash", "-c", "tf2/srcds_run -game tf -insecure +sv_pure 1 +map ctf_hellfire +maxplayers 6"]
