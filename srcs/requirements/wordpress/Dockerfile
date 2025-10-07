FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      php-fpm php-mysql php-cli php-curl php-xml php-mbstring php-zip php-gd \
      curl ca-certificates unzip wget less git mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# php-fpm pool config (PHP 8.2 on Debian Bookworm)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# WP-CLI
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

# entrypoint prepares wp on first run and completes install via WP-CLI
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000
WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2","-F"]
