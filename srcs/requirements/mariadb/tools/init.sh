#!/bin/bash
set -euo pipefail

SOCK="/run/mysqld/mysqld.sock"
PIDF="/run/mysqld/mysqld.pid"
DATADIR="/var/lib/mysql"

: "${MYSQL_DATABASE:?}"
: "${MYSQL_USER:?}"

DB_ROOT_PASS="$(tr -d '\r\n' < /run/secrets/db_root_password)"
DB_PASS="$(tr -d '\r\n' < /run/secrets/db_password)"

mkdir -p "$(dirname "$SOCK")"
chown -R mysql:mysql "$(dirname "$SOCK")" "$DATADIR"

# If database directory is empty, initialize system tables
if [ ! -d "$DATADIR/mysql" ]; then
  echo "[init] Fresh install - initializing database..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" --basedir=/usr --skip-test-db
fi

# On every start ensure target DB and user exist via init file (single start)
ENSURE_SQL="/tmp/ensure.sql"
cat > "$ENSURE_SQL" <<SQL
-- Secure root and remove anonymous users (safe to run repeatedly)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';

-- Ensure application database and user
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
chown mysql:mysql "$ENSURE_SQL"

# Start MariaDB once, executing the ensure SQL at boot
exec /usr/sbin/mysqld \
  --user=mysql \
  --datadir="$DATADIR" \
  --socket="$SOCK" \
  --pid-file="$PIDF" \
  --console \
  --init-file="$ENSURE_SQL"