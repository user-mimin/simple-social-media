# Gunakan image resmi PHP dengan Apache sebagai base image
FROM php:8.2-apache

# Atur direktori kerja ke /var/www/html
WORKDIR /var/www/html/

# Instal dependensi sistem yang diperlukan
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal ekstensi PHP yang diperlukan
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Aktifkan modul Apache yang diperlukan
RUN a2enmod rewrite

# Instal Composer secara global
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Salin file composer.json dan composer.lock ke direktori kerja
COPY composer.json composer.lock ./

# Tambahkan konfigurasi allow-plugins untuk keamanan tambahan
RUN composer config --global allow-plugins true

# Instal dependensi aplikasi
RUN composer install --no-scripts --no-autoloader

# Salin seluruh kode aplikasi ke direktori kerja
COPY . .

# Pastikan direktori cache Laravel ada dan writable
RUN mkdir -p bootstrap/cache storage/framework/cache storage/framework/views storage/logs && \
    chown -R www-data:www-data bootstrap storage && \
    chmod -R 755 bootstrap storage 

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Generate autoload files dan cache
RUN composer dump-autoload
RUN php artisan config:cache

# Setel izin untuk direktori storage dan bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Setel document root ke direktori public
#ENV APACHE_DOCUMENT_ROOT /var/www/html/public
#RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Tambahkan konfigurasi Apache
COPY sosmed.conf /etc/apache2/sites-available/000-default.conf

RUN a2ensite 000-default.conf

RUN chmod +x install.sh

# Ekspose port 80 untuk Apache
EXPOSE 80

# Jalankan perintah untuk memulai Apache
CMD ["apache2-foreground", "./install.sh"]
