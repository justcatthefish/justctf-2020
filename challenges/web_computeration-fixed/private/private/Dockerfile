FROM debian:sid

ENV NODE_ENV "production"

RUN apt update && \
    apt install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt install -y nodejs

RUN groupadd -g 99999 justctf && \
    useradd --uid 99999 --gid 99999 justctf && \
    mkdir /home/justctf && \
    chown justctf /home/justctf -R && \
    chmod 755 /home/justctf -R

WORKDIR /home/justctf/

COPY src/ /home/justctf/

# nie wiem co to, ale bylo zeby dodac xd
# RUN npm ci --only=production
# ENV NODE_ENV "production"

RUN npm install

USER justctf

EXPOSE 80
CMD [ "node", "app.js" ]

