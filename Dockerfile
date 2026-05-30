FROM php:8.3-fpm-alpine

WORKDIR /var/www/html

# ─── System packages ───────────────────────────────────────────────────
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    git \
    curl \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    unzip

# ─── PHP extensions ────────────────────────────────────────────────────
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    zip \
    gd \
    mbstring \
    opcache

# ─── Composer ──────────────────────────────────────────────────────────
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# ─── App files ─────────────────────────────────────────────────────────
COPY . .

# ─── Install dependencies ──────────────────────────────────────────────
RUN composer install --no-dev --optimize-autoloader --no-interaction
RUN npm ci && npm run build

# ─── Permissions ───────────────────────────────────────────────────────
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ─── Nginx config ──────────────────────────────────────────────────────
COPY docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# php-fpm + nginx একসাথে চালাও
CMD sh -c "php-fpm -D && nginx -g 'daemon off;'"
