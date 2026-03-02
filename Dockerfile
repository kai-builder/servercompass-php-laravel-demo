# syntax=docker/dockerfile:1
# ── Stage 1: Composer dependency install ─────────────────────────────────────
FROM composer:2 AS composer-deps

WORKDIR /app

# Copy only manifest files first — cached until composer.json/lock changes
COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --no-progress \
    --no-interaction

# Copy full source, then generate optimised autoloader
COPY . .
RUN composer dump-autoload --optimize --no-dev

# ── Stage 2: Production runtime ──────────────────────────────────────────────
FROM php:8.4-fpm-alpine AS runtime

# Install system packages and PHP extensions in a single RUN
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apk add --no-cache nginx supervisor curl sqlite-dev wget gettext \
    && install-php-extensions pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd zip opcache \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www/html

# Copy application from composer stage
COPY --from=composer-deps /app ./

# Ensure .env.example is present for entrypoint
COPY .env.example .env.example

# Create required directories and set permissions
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions \
             storage/framework/views bootstrap/cache database /run/nginx \
    && touch storage/logs/laravel.log database/database.sqlite \
    && chown -R www-data:www-data storage bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache

# ── Nginx config ─────────────────────────────────────────────────────────────
COPY <<'EOF' /etc/nginx/http.d/default.conf.template
server {
    listen ${PORT};
    server_name _;
    root /var/www/html/public;
    index index.php;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* { deny all; }
}
EOF

# ── Supervisor config ────────────────────────────────────────────────────────
COPY <<'EOF' /etc/supervisord.conf
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

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PORT=80
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:${PORT}/api/health || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
