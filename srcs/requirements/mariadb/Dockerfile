FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      mariadb-server mariadb-client dumb-init tzdata ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /etc/mysql/conf.d && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306
ENV MYSQL_DATABASE=wordpress MYSQL_USER=wpuser

ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["/usr/local/bin/init.sh"]
