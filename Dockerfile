# Use official PHP 8.2 image with Apache
FROM php:8.2-apache

# Install system dependencies and PHP extensions
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

# Download and extract GLPI
RUN mkdir -p /tmp/glpi \
    && curl -fsSL https://github.com/glpi-project/glpi/releases/download/11.0.0-beta2/glpi-11.0.0-beta2.tgz -o /tmp/glpi.tgz \
    && tar -xzf /tmp/glpi.tgz -C /tmp/glpi --strip-components=1 \
    && rm /tmp/glpi.tgz

# Move GLPI to web root
RUN mv /tmp/glpi/* /var/www/html/ \
    && mv /tmp/glpi/.* /var/www/html/ || true \
    && rm -rf /tmp/glpi

# Configure Apache for GLPI 11 public directory
RUN a2enmod rewrite \
    && sed -i 's#/var/www/html#/var/www/html/public#' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's#/var/www/html#/var/www/html/public#' /etc/apache2/apache2.conf \
    && echo "DocumentRoot /var/www/html/public" > /etc/apache2/conf-available/glpi.conf \
    && echo "<Directory /var/www/html/public>" >> /etc/apache2/conf-available/glpi.conf \
    && echo "    Options FollowSymLinks" >> /etc/apache2/conf-available/glpi.conf \
    && echo "    AllowOverride All" >> /etc/apache2/conf-available/glpi.conf \
    && echo "    Require all granted" >> /etc/apache2/conf-available/glpi.conf \
    && echo "</Directory>" >> /etc/apache2/conf-available/glpi.conf \
    && a2enconf glpi

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && mkdir -p /var/www/html/files \
    && chown www-data:www-data /var/www/html/files

# Configure cron
RUN echo "* * * * * www-data /usr/local/bin/php /var/www/html/public/front/cron.php --force > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/glpi \
    && chmod 0644 /etc/cron.d/glpi

# PHP configuration
COPY glpi.ini /usr/local/etc/php/conf.d/

EXPOSE 80
CMD ["bash", "-c", "cron && apache2-foreground"]