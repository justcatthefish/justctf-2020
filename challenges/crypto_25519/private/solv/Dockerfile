FROM sagemath/sagemath:9.1

WORKDIR /home/sage
USER sage

RUN sage -pip install typer pwntools
COPY solve.sage /home/user/

CMD "sage -python /home/user/solve.sage 127.0.0.1 1337"
