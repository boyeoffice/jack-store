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
RUN apk --no-cache add shadow && \
	groupmod -o -g ${GID} symfony && \
	usermod -o -u ${UID} -g symfony symfony

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
	chown symfony:symfony ${APP_PATH}
COPY --chown=symfony:symfony ./ ${APP_PATH}
WORKDIR ${APP_PATH}

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
USER symfony
ARG BUILD_MODE=dev
RUN if [ ${BUILD_MODE} = dev ]; \
	then \
		composer install --no-interaction; \
	else \
		composer install --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader; \
	fi;
RUN chown -R symfony:symfony ${APP_PATH}/vendor/
COPY ./.docker/php/local.ini /usr/local/etc/php/conf.d/local.ini

EXPOSE 80

COPY ./.docker/entrypoint.sh /

ENTRYPOINT ["sh", "./.docker/entrypoint.sh"]
