# Use an official PHP runtime as a parent image
FROM php:apache

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev

# Clear the apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Enable Apache modules
RUN a2enmod rewrite

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.json and composer.lock to the working directory
# Copy the rest of the application code
ADD ./ .

# Install application dependencies
RUN composer install --no-scripts --no-autoloader


# Generate autoload files and cache
RUN composer dump-autoload
RUN php artisan config:cache

# Set permissions for storage and bootstrap cache
RUN chown -R www-data:www-data .
RUN chmod -R 755 storage

# Set the document root to the public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Update the default Apache virtual host configuration
ADD ./sosmed.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80 for Apache
EXPOSE 80

# Start Apache
#CMD ["apache2-foreground","./var/www/html/install.sh"]
ENTRYPOINT ["sh", "install.sh"]
