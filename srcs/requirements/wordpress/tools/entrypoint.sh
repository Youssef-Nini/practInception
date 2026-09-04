#!/bin/bash

set -e
cd /var/www/html

echo "here ====>1"

for i in {1..30}; do
	if mysqladmin ping -h "mariadb" --silent; then
		break
	fi
	sleep 1
done

echo "he enter here"

if ! wp core is-installed --allow-root &>/dev/null; then
	if [ ! -f "index.php" ]; then
		wp core download --allow-root
	fi

	wp config create \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbhost="mariadb:3306" \
		--allow-root

	wp core install \
		--url=$DOMAIN_NAME \
		--title=$WORDPRESS_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL \
		--skip-email \
		--allow-root

	wp user create \
		$WP_USER \
		$WP_USER_EMAIL \
		--user_pass=$WP_USER_PASSWORD \
		--role=author \
		--allow-root
fi
echo "here ====>222"
chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F