FROM gabrieltakacs/alpine:latest
MAINTAINER Gabriel Takács <gtakacs@gtakacs.sk>

# Copy and add files first (to make dockerhub autobuild working: https://forums.docker.com/t/automated-docker-build-fails/22831/14)
COPY run.sh /run.sh

# Install nginx, supservisor, PHP 7
RUN apk --no-cache --update add \
    nginx \
    supervisor \
    php7 \
    php7-fpm \
    php7-xml \
    php7-pgsql \
    php7-pdo_pgsql \
    php7-mysqli \
    php7-pdo_mysql \
    php7-mcrypt \
    php7-opcache \
    php7-gd \
    php7-curl \
    php7-json \
    php7-phar \
    php7-openssl \
    php7-ctype \
    php7-mbstring \
    php7-zip \
    php7-dev \
    php7-xdebug \
    php7-session \
    php7-dom \
    php7-pcntl \
    php7-posix \
    php5-memcache \
    php5-memcached \
    php5-imagick \
    memcached \
    imagemagick \
    postfix

# Install NPM & NPM modules (gulp, bower)
RUN apk --no-cache --update add nodejs
RUN npm install --silent -g \
    gulp \
    bower

# Install composer
ENV COMPOSER_HOME=/composer
RUN mkdir /composer \
    && curl -sS https://getcomposer.org/installer | php7 \
    && mv composer.phar /usr/bin/composer

# php7-fpm configuration
RUN adduser -s /sbin/nologin -D -G www-data www-data
COPY php7/php-fpm.conf /etc/php7/php-fpm.conf
COPY php7/www.conf /etc/php7/php-fpm.d/www.conf

# Link php7 binary to php
RUN ln -s /usr/bin/php7 /usr/bin/php

# Configure xdebug
RUN echo "xdebug.remote_enable=on" >> /etc/php7/php.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php7/php.ini \
    && echo "xdebug.remote_connect_back=0" >> /etc/php7/php.ini \
    && echo "xdebug.remote_port=9001" >> /etc/php7/php.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php7/php.ini \
    && echo "xdebug.remote_host=192.168.65.1" >> /etc/php7/php.ini
    # (Only for MAC users) Fill IP address from:
    # cat /Users/gtakacs/Library/Containers/com.docker.docker/Data/database/com.docker.driver.amd64-linux/slirp/host
    # Source topic on Docker forums: https://forums.docker.com/t/ip-address-for-xdebug/10460/22

# Copy Supervisor config file
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /etc/nginx/vhosts
COPY web.conf /etc/nginx/vhosts/web.conf

# Make run file executable
RUN chmod a+x /run.sh

EXPOSE 80 443
CMD ["/run.sh"]
WORKDIR /var/www/web
