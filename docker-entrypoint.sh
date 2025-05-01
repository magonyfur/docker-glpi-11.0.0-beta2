#!/bin/bash
set -e

# Create required directories if they don't exist
mkdir -p /var/www/html/files/_cache \
    /var/www/html/files/_cron \
    /var/www/html/files/_dumps \
    /var/www/html/files/_graphs \
    /var/www/html/files/_lock \
    /var/www/html/files/_pictures \
    /var/www/html/files/_plugins \
    /var/www/html/files/_rss \
    /var/www/html/files/_sessions \
    /var/www/html/files/_tmp \
    /var/www/html/files/_uploads

# Set permissions
chown -R www-data:www-data /var/www/html/files
chmod -R 775 /var/www/html/files

# Start cron service
service cron start

# Execute the CMD
exec "$@"