FROM drupal:9.1.4-php7.4-apache

RUN apt-get update && apt-get install -y \
  git \
  imagemagick \
  libmagickwand-dev \
  mariadb-client \
  rsync \
  sudo \
  unzip \
  vim \
  wget \
  && docker-php-ext-install bcmath \
  && docker-php-ext-install mysqli \
  && docker-php-ext-install pdo \
  && docker-php-ext-install pdo_mysql

# Remove the memory limit for the CLI only.
RUN echo 'memory_limit = -1' > /usr/local/etc/php/php-cli.ini

# Remove the vanilla Drupal project that comes with this image.
RUN rm -rf ..?* .[!.]* *
WORKDIR /
RUN mkdir app

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/html!/app/docroot!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www!/app/docroot!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Robo CI.
ENV PATH="/app/vendor/bin:${PATH}"

RUN chown www-data:www-data /app
WORKDIR /app
