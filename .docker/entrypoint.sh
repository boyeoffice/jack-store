#!/bin/sh

echo "🎬 entrypoint.sh"

composer dump-autoload --no-interaction --no-dev --optimize

echo "🎬 artisan commands"

# php artisan cache:clear
# php artisan migrate --no-interaction --force
# php artisan db:seed --no-interaction --force

echo "🎬 start supervisord"

supervisord -c $APP_PATH/.docker/config/supervisord.conf
