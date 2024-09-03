FROM sagemath/sagemath:9.1

USER root
RUN apt-get -y update && apt -y install socat

# sage is non-root user
WORKDIR /home/sage
USER sage

COPY flag.txt /home/sage/
COPY task.sage /home/sage/

CMD "socat tcp-l:1337,reuseaddr,fork EXEC:'sage /home/sage/task.sage'"
