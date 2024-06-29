FROM php:8.2-fpm-alpine

ARG UID
ARG GID

# Install system dependencies
RUN apk add --no-cache dcron busybox-suid libcap curl zip unzip git  build-base zlib-dev oniguruma-dev autoconf bash
RUN apk add --update linux-headers

# Xdebug
#ARG INSTALL_XDEBUG=false

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions intl bcmath gd pdo_mysql opcache redis uuid exif pcntl zip

# Install composer
COPY --from=composer/composer:latest /usr/bin/composer /usr/local/bin/composer

# Set working directory
ENV APP_PATH=/srv/app
WORKDIR $APP_PATH

# Add non-root user: 'app'
ENV NON_ROOT_GROUP symfony
ENV NON_ROOT_USER symfony
RUN addgroup -S $NON_ROOT_GROUP && adduser -S $NON_ROOT_USER -G $NON_ROOT_GROUP

# RUN groupadd -g "${GID}" symfony
# RUN useradd -u "${UID}" -g "${GID}" symfony

# Switch to non-root 'app' user & install app dependencies
COPY composer.json composer.lock ./
RUN chown -R $NON_ROOT_USER:$NON_ROOT_GROUP $APP_PATH
USER $NON_ROOT_USER
RUN composer install --no-interaction
RUN rm -rf /home/$NON_ROOT_USER/.composer

# Copy app
COPY --chown=$NON_ROOT_USER:$NON_ROOT_GROUP . $APP_PATH/

RUN chmod +x bin/console

EXPOSE 80

# Run command to start Symfony
# CMD ["php", "bin/console", "server:run", "--env=dev", "--host=0.0.0.0"]
