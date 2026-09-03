#!/bin/bash

set -e

if [ ! -d /var/lib/mysql/mysql ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1

	mysqld --user=mysql --datadir=/var/lib/mysql &
	pid="$!"
	echo "here 1"
	for i in {1..30}; do
		if mysqladmin ping >/dev/null 2>&1; then
			break
		fi
		sleep 1
	done

	echo "here 2"
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
	mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	mysql -u root -e "FLUSH PRIVILEGES;"

	kill "$pid"
	wait "$pid"q
fi
	echo "here 3"

exec mysqld --user=mysql --datadir=/var/lib/mysql
