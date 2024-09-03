FROM php:7.4-apache
COPY src-docker/ /var/www/html/
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
EXPOSE 80