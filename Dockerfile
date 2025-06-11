# Use official PHP 8.2 image with Apache
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev \
    libonig-dev libxml2-dev libldap2-dev libzip-dev libbz2-dev \
    libicu-dev libpq-dev zip unzip cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd pdo_mysql mysqli pdo_pgsql mbstring exif pcntl \
        bcmath soap ldap zip bz2 intl opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create directory structure first
RUN mkdir -p /var/www/html/public \
    && chown -R www-data:www-data /var/www/html

# Download and extract GLPI to temporary location
RUN mkdir -p /tmp/glpi \
    && curl -fsSL https://github.com/glpi-project/glpi/releases/download/11.0.0-beta2/glpi-11.0.0-beta2.tgz -o /tmp/glpi.tgz \
    && tar -xzf /tmp/glpi.tgz -C /tmp/glpi --strip-components=1 \
    && rm /tmp/glpi.tgz

# Move files to correct locations
RUN mv /tmp/glpi/* /var/www/html/ \
    && mv /tmp/glpi/.* /var/www/html/ || true \
    && rm -rf /tmp/glpi

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Configure Apache
RUN a2enmod rewrite \
    && echo "<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
        RewriteEngine On\n\
        RewriteCond %{REQUEST_FILENAME} !-f\n\
        RewriteCond %{REQUEST_FILENAME} !-d\n\
        RewriteRule ^(.*)$ index.php [QSA,L]\n\
    </Directory>\n\
    ErrorLog \${APACHE_LOG_DIR}/error.log\n\
    CustomLog \${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Configure cron (log to stdout)
RUN echo "* * * * * www-data /usr/local/bin/php /var/www/html/public/front/cron.php --force > /proc/1/fd/1 2>&1" > /etc/cron.d/glpi \
    && chmod 0644 /etc/cron.d/glpi

# PHP configuration
RUN echo "memory_limit = 256M\n\
upload_max_filesize = 64M\n\
post_max_size = 64M\n\
max_execution_time = 600\n\
session.cookie_httponly = 1\n\
session.cookie_secure = 0\n\
session.use_strict_mode = 1" > /usr/local/etc/php/conf.d/glpi.ini

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

# Startup script
ADD https://raw.githubusercontent.com/magonyfur/docker-glpi-11.0.0-beta2/refs/heads/master/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]