FROM debian:stable-slim

RUN apt-get update -y \
	&& apt-get install mariadb-server -y \
	&& rm -rf /var/lib/apt/lists/*

COPY ./tools/init.sh usr/local/bin/mariadb.sh
COPY ./conf/99-server.cnf /etc/mysql/mariadb.cnf.d/99-server.cnf

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

ENTRYPOINT["/usr/local/bin/maridadb.sh"]
