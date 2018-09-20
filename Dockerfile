FROM php:7.2.10-fpm

ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_ALLOW_SUPERUSER 1

# install base packages
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends apt-utils gnupg && \
    apt-get install -y --no-install-recommends locales locales-all unzip vim cron procps && \
    apt-get install -y --no-install-recommends libicu-dev && \
    locale-gen en_US.UTF-8 && \
    update-locale

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN docker-php-ext-install opcache && \
    docker-php-ext-install intl && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 12M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /usr/local/etc/php/php.ini && \
    sed -i "s/;error_log =.*/error_log = \/proc\/self\/fd\/2/" /usr/local/etc/php-fpm.conf && \
    sed -i "s/listen = .*/listen = 9000/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_children = .*/pm.max_children = 200/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 56/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 32/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 96/" /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

COPY . /var/www/html

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- && \
    php composer.phar --version

## for more speed
#RUN php composer.phar global config repos.packagist composer https://packagist.jp && \
#    php composer.phar global require hirak/prestissimo

## composer install for lumen
RUN php composer.phar install --no-dev --no-scripts && \
    php composer.phar dumpautoload --optimize

# change directory permission
RUN chown -R www-data:www-data /var/www/html/storage

VOLUME /var/www/html
