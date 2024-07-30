cp .env.example .env
php artisan key:generate

sed -i 's/DB_HOST=127.0.0.1/DB_HOST=192.168.3.2/g' .env &&
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env &&

php artisan migrate
php artisan db:seed
