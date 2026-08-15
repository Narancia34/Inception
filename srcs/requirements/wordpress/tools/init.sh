#!/bin/bash

if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\r\n')
fi

# Navigate to the Nginx document root
cd /var/www/html

# Check if WordPress is already installed to prevent wiping data on container restart
if [ ! -f wp-config.php ]; then
    echo "WordPress not found. Starting installation..."

    # 1. Download WP-CLI (Command Line Interface for WordPress)
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # 2. Download WordPress core files
    wp core download --allow-root

    # 3. Wait for MariaDB to be ready before attempting to connect
    echo "Waiting for MariaDB to start..."
    while ! mariadb -h mariadb -u "${DB_USER}" -p"${DB_PASSWORD}" -e "USE ${DATA_BASE};" &> /dev/null; do
        sleep 3
    done
    echo "MariaDB is ready! Configuring WordPress..."

    # 4. Generate wp-config.php linking WordPress to the database
    wp config create --allow-root \
        --dbname="${DATA_BASE}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb"

    # 5. Install WordPress and create the Admin user
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception 42" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # 6. Create the mandatory second regular user (Author role)
    wp user create --allow-root \
        "${WP_REGULAR_USER}" "${WP_REGULAR_EMAIL}" \
        --user_pass="${WP_REGULAR_PASSWORD}" \
        --role=author

    # 7. Ensure correct ownership so Nginx and PHP-FPM can read/write the files
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html

    echo "WordPress installation complete!"
else
    echo "WordPress is already installed. Skipping setup."
fi

# 8. Start PHP-FPM in the foreground (PID 1)
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
