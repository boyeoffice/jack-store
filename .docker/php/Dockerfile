FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache dcron busybox-suid libcap curl zip unzip git  build-base zlib-dev oniguruma-dev autoconf bash
RUN apk add --update linux-headers

# Xdebug
ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; \
	then \
		pecl install xdebug && docker-php-ext-enable xdebug; \
	fi;

COPY ./.docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Mysql
RUN apk add --no-cache libpq-dev && docker-php-ext-install pdo_mysql mysqli

# Configure non-root user
ARG UID
ARG GID
ENV NON_ROOT_GROUP symfony
ENV NON_ROOT_USER symfony
RUN apk --no-cache add shadow && \
	groupmod -o -g ${GID} www-data && \
	usermod -o -u ${UID} -g www-data www-data

# Nginx
# RUN apk add --update --no-cache nginx
# COPY ./.docker/php/nginx.conf /etc/nginx/
# RUN chown -Rf www-data:www-data /var/lib/nginx

# Install caddy
COPY --from=caddy:2.2.1 /usr/bin/caddy /usr/local/bin/caddy
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

# Supervisor
RUN apk add --no-cache supervisor
COPY ./.docker/php/supervisord.conf /etc/supervisord.conf

# Source code
ENV APP_PATH=/srv/app
RUN mkdir ${APP_PATH} && \
	chown www-data:www-data ${APP_PATH}
COPY --chown=www-data:www-data ./ ${APP_PATH}
WORKDIR ${APP_PATH}

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
USER www-data
ARG BUILD_MODE=dev
RUN if [ ${BUILD_MODE} = dev ]; \
	then \
		composer install --no-interaction; \
	else \
		composer install --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader; \
	fi;
RUN chown -R www-data:www-data ${APP_PATH}/vendor/

EXPOSE 8080

ENTRYPOINT ["sh", "./.docker/php/run.sh"]
