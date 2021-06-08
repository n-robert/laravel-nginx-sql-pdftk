FROM php:7.4.1-apache

# 1. development packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        nano \
        libicu-dev \
        git \
        zip \
        unzip \
        vim \
 && rm -rf /var/lib/apt/lists/*

# 2. apache configs + document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# 4. start with base php config, then add extensions
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync \
 && install-php-extensions bz2 \
        gettext \
        intl \
        exif \
        pdo_pgsql \
        bcmath

# 5. pdftk
RUN mkdir /usr/share/man/man1/ \
 && apt-get update \
 && apt-get install -y pdftk
