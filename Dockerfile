FROM drupal:9.1-php7.4-apache

ENV NODE_VERSION=14.x

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

# Create and make /app as the mounting directory.
WORKDIR /
RUN mkdir app

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/html!/app/docroot!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www!/app/docroot!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Make all vendor binaries availabe in PATH.
ENV PATH="/app/vendor/bin:${PATH}"

# Install Robo.
RUN wget https://robo.li/robo.phar && \
    chmod +x robo.phar && mv robo.phar /usr/local/bin/robo

# Install Chrome browser.
RUN apt-get install --yes gnupg2 apt-transport-https
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install --yes google-chrome-unstable

# Install Node and Yarn
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash -
RUN apt-get install -y nodejs
RUN npm install -g gulp-cli
RUN npm install -g yarn

RUN chown www-data:www-data /app
WORKDIR /app
