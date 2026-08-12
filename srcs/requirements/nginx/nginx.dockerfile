FROM debian:stable-slim

RUN apt-get update -y \
    && apt-get install nginx -y \
    && apt-get install openssl -y

RUN openssl req -x509 -newkey rsa:2048 -nodes -batch \
    -keyout /etc/nginx/priv.key -out /etc/nginx/server.crt

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /test
COPY index.html /test/index.html

EXPOSE 443

CMD ["-g", "daemon off;"]

ENTRYPOINT [ "nginx" ]
