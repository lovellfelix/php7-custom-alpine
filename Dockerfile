FROM alpine:3.15.0    

RUN apk --no-cache add \
    tzdata \
    bash shadow \
    curl ca-certificates openssl openssh \
    apache2 apache2-http2  \
    zip unzip ffmpeg \
    php7 \
    php7-apache2 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-ftp \
    php7-gd \
    php7-gettext \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mysqlnd \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_sqlite \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pear \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-sqlite3 \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
    php7-zlib 

RUN cp /usr/bin/php7 /usr/bin/php \
    && rm -f /var/cache/apk/*

# Add apache to run and configure
RUN echo '*** Apache modules...' \
    && sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ unique_id_module/LoadModule\ unique_id_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ cache_module/LoadModule\ cache_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ cache_socache_module/LoadModule\ cache_socache_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/html/app\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/var/www/html/app#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/var/www/html/app\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

RUN mkdir -p /var/www/html/app && chown -R apache:apache /var/www/html/app && chmod -R 755 /var/www/html/app && mkdir bootstrap

RUN sed -ri \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
    -e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
    /etc/apache2/httpd.conf

ADD start.sh /bootstrap/
RUN chmod +x /bootstrap/start.sh

VOLUME /var/www/html

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]
WORKDIR /var/www/html/app

