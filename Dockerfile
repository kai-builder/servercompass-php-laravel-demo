FROM php:8.4-fpm-alpine

# Install dependencies and PHP extensions in one layer
# Using install-php-extensions for MUCH faster builds (pre-compiled)
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN apk add --no-cache nginx supervisor curl sqlite-dev \
    && install-php-extensions pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd zip opcache \
    && rm -rf /var/cache/apk/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for dependency caching
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-progress

# Copy application files
COPY . .

# Setup environment, generate key if needed, and set permissions
RUN composer dump-autoload --optimize \
    && cp -n .env.example .env || true \
    && php artisan key:generate --force \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 storage bootstrap/cache \
    && touch database/database.sqlite \
    && chown www-data:www-data database/database.sqlite \
    && mkdir -p /run/nginx

# Configure Nginx
COPY <<EOF /etc/nginx/http.d/default.conf
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \\.php\$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\\.(?!well-known).* {
        deny all;
    }
}
EOF

# Configure Supervisor
COPY <<EOF /etc/supervisord.conf
[supervisord]
nodaemon=true
user=root
logfile=/dev/null
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid

[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
