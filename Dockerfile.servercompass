FROM ghcr.io/railwayapp/nixpacks:ubuntu-1745885067

ENTRYPOINT ["/bin/bash", "-l", "-c"]
WORKDIR /app/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
ENV PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
ENV PATH="/usr/local/bin:${PATH}"
RUN apt-get update \
    && apt-get install -y php php-cli php-fpm php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -sf /usr/local/bin/composer /usr/bin/composer



ARG IS_LARAVEL NIXPACKS_METADATA NIXPACKS_PHP_ROOT_DIR PORT
ENV IS_LARAVEL=$IS_LARAVEL NIXPACKS_METADATA=$NIXPACKS_METADATA NIXPACKS_PHP_ROOT_DIR=$NIXPACKS_PHP_ROOT_DIR PORT=$PORT

# setup phase
# noop

# install phase
COPY . /app/.
RUN  mkdir -p /var/log/nginx && mkdir -p /var/cache/nginx
RUN  composer install --ignore-platform-reqs
RUN  npm i

# build phase
COPY . /app/.
RUN  npm run build





# start
COPY . /app

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=${PORT:-3000}"]
CMD ["node", "index.js"]