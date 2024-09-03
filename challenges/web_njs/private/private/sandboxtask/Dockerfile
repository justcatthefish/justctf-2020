FROM nginx:1.19.5-alpine

COPY server.js /etc/nginx/server.js
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
COPY flag.txt /home/RealFlagIsHere1337.txt
RUN chmod +x /run.sh && mkdir -p /tmp/task/ && chmod 777 /tmp/task/

CMD ["/run.sh"]
