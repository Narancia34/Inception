#!/bin/bash

# Read the secret password
DB_PASSWORD=$(cat /run/secrets/db_password)

# Ensure runtime directory exists and has correct permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 1. Initialize system tables if the volume is completely empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# 2. Check if your specific database has been created yet
if [ ! -d "/var/lib/mysql/$DATA_BASE" ]; then

    # Start the daemon in the background to accept configuration
    mariadbd --user=mysql &
    pid=$!

    # 3. health check
    until mariadb-admin ping >/dev/null 2>&1; do
        sleep 1
    done

    # Run the setup queries
    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${DATA_BASE}\`;"
    mariadb -u root -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${DATA_BASE}\`.* TO \`${DB_USER}\`@'%';"
    mariadb -u root -e "FLUSH PRIVILEGES;"

    # 4. Graceful shutdown waiting for the background process to exit
    mariadb-admin -u root shutdown
    wait $pid
fi

# 5. Hand over PID 1 to the daemon in the foreground
exec mariadbd --user=mysql
