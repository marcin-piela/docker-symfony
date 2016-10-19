FROM debian:jessie

MAINTAINER Marcin Piela

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      curl \
      nginx \
      sqlite3 \
	php7.0-fpm \
      php7.0-cli \
	php7.0-bcmath \
	php7.0-curl \
	php7.0-intl \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-pgsql \
	php-memcached \
	php7.0-sqlite3 \
	php7.0-mbstring \
	php7.0-zip \
      php7.0-gd \
	php7.0-xml \
      supervisor \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM & Nginx
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php7.0/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php7.0/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php7.0/fpm/pool.d/www.conf \
    && echo "opcache.enable=1" >> /etc/php7.0/mods-available/opcache.ini \
    && echo "opcache.enable_cli=1" >> /etc/php7.0/mods-available/opcache.ini \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN sed -i  -e "s/\(post_max_size =\).*/\1 50M/g" /etc/php7.0/cli/php.ini
RUN sed -i  -e "s/\(upload_max_filesize =\).*/\1 50M/g" /etc/php7.0/cli/php.ini
RUN sed -i  -e "s/\(max_execution_time =\).*/\1 300/g" /etc/php7.0/cli/php.ini
RUN sed -i  -e "s/\(post_max_size =\).*/\1 50M/g" /etc/php7.0/fpm/php.ini
RUN sed -i  -e "s/\(upload_max_filesize =\).*/\1 50M/g" /etc/php7.0/fpm/php.ini
RUN sed -i  -e "s/\(max_execution_time =\).*/\1 300/g" /etc/php7.0/fpm/php.ini

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data

VOLUME /var/www
WORKDIR /var/www

RUN chown -R www-data:www-data /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord"]
