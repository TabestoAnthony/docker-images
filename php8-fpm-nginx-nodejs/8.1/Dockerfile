FROM php:8.1.18-fpm

ARG APP_ENV

ENV COMPOSER_VERSION=2.5.8 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    NGINX_VERSION=1.20.2-1~buster \
    TIMEZONE=Europe/Paris

COPY ./php-fpm/conf/php.ini /usr/local/etc/php/conf.d/docker-php-config.ini
COPY ./php-fpm/conf/docker.conf /usr/local/etc/php-fpm.d/zzz-docker.conf
COPY --from=composer:2.5.5 /usr/bin/composer /usr/bin/composer
COPY ./entrypoint.sh /

# install the dependencies
RUN apt-get update && apt-get install -y \
    gnupg \
    g++ \
    procps \
    openssl \
    git \
    unzip \
    zlib1g-dev \
    libzip-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libicu-dev  \
    libonig-dev \
    libxslt1-dev \
    acl \
    supervisor \
    default-mysql-client \
    && echo 'alias sf="php bin/console"' >> ~/.bashrc

RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install pdo pdo_mysql zip xsl gd intl opcache exif mbstring && \
    chmod +x /entrypoint.sh && \
    ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini && \
    "date"

RUN if [ "$APP_ENV" = "test" ] ; then pecl install xdebug && docker-php-ext-enable xdebug && \
     echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
     echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; fi

# install nginx
RUN NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
	found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
	echo "deb http://nginx.org/packages/debian/ buster nginx" >> /etc/apt/sources.list.d/nginx.list && \
	apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -y nginx=${NGINX_VERSION} && \
	rm -rf /var/lib/apt/lists/*

# copy the nginx configuration files
COPY ./nginx/ /etc/nginx/

# install nodejs16.x
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# tidy up
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy the supervisord conf files to handle php-fpm and nginx in the same container
COPY ./supervisord/ /etc/supervisor/conf.d/

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["background"]
