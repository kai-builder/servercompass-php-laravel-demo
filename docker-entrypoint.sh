#!/bin/sh
set -e

cd /var/www/html

# Create .env from example if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate APP_KEY if not already set via env var or .env file
if [ -z "$APP_KEY" ] && ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    php artisan key:generate --force
fi

# If APP_KEY is passed as env var, write it into .env so Laravel picks it up
if [ -n "$APP_KEY" ]; then
    sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" .env
fi

# Ensure storage directories exist and are writable
mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
touch storage/logs/laravel.log
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Create SQLite database if using sqlite
if grep -q "^DB_CONNECTION=sqlite" .env 2>/dev/null; then
    touch database/database.sqlite
    chown www-data:www-data database/database.sqlite
fi

# Run migrations (safe to re-run, --force for production)
php artisan migrate --force 2>/dev/null || true

# Cache config for performance
php artisan config:cache 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

# Render nginx config with actual PORT value (default 80)
export PORT="${PORT:-80}"
envsubst '${PORT}' < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

# Start supervisor
exec supervisord -c /etc/supervisord.conf
