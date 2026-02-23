#!/bin/sh
set -e

cd /var/www/html

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate APP_KEY if not set
if [ -z "$APP_KEY" ] && ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    php artisan key:generate --force
fi

# Ensure storage directories exist and are writable
mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
touch storage/logs/laravel.log
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Create SQLite database if needed
touch database/database.sqlite
chown www-data:www-data database/database.sqlite

# Start supervisor
exec supervisord -c /etc/supervisord.conf
