FROM debian:bookworm-slim

RUN apt-get update -y \
	&& apt-get install php-fpm php-mysql curl mariadb-client -y \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/init.sh /usr/local/bin/wordpress.sh
RUN chmod +x /usr/local/bin/wordpress.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
