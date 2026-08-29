FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]