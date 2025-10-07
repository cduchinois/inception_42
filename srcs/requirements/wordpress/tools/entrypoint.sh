#!/bin/bash
set -euo pipefail

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(tr -d '\r\n' < /run/secrets/db_password)"
DB_HOST="mariadb"

WP_URL="${WP_URL}"
WP_TITLE="${WP_TITLE}"
WP_ADMIN_USER="${WP_ADMIN_USER}"
WP_ADMIN_PASS="$(tr -d '\r\n' < /run/secrets/wp_admin_password)"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"

SECOND_USER="${WP_USER_NAME:-}"
SECOND_EMAIL="${WP_USER_EMAIL:-}"
SECOND_PASS="${WP_USER_PASS:-userpass123}"

# 1) First-run: fetch WordPress into the bind volume and prepare wp-config.php
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "[wp] Installing WordPress core files into volume..."
  rm -rf /var/www/html/*
  wget -q https://wordpress.org/latest.zip
  unzip -q latest.zip
  mv wordpress/* .
  rmdir wordpress
  rm latest.zip

  cp wp-config-sample.php wp-config.php
  # Safer than sed: works with any special chars in passwords
  wp config set DB_NAME     "$DB_NAME"     --type=constant --allow-root --path=/var/www/html
  wp config set DB_USER     "$DB_USER"     --type=constant --allow-root --path=/var/www/html
  wp config set DB_HOST     "$DB_HOST"     --type=constant --allow-root --path=/var/www/html
  wp config set DB_PASSWORD "$DB_PASS"     --type=constant --allow-root --path=/var/www/html

  chown -R www-data:www-data /var/www/html
fi

# 2) Wait for DB using WP-CLI (tries to connect using wp-config.php)
for i in {1..60}; do
  if wp db check --path=/var/www/html --allow-root >/dev/null 2>&1; then
    break
  fi
  echo "[wp] waiting for database... ($i/60)"
  sleep 1
done

# 3) Install core if needed
if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
  echo "[wp] Running wp core install..."
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --path=/var/www/html \
    --allow-root
fi

# 4) Create the second user (role: editor)
if [ -n "${SECOND_USER}" ] && ! wp user get "${SECOND_USER}" --allow-root --path=/var/www/html >/dev/null 2>&1; then
  echo "[wp] Creating second user: ${SECOND_USER}"
  wp user create "${SECOND_USER}" "${SECOND_EMAIL}" \
    --role=editor \
    --user_pass="${SECOND_PASS}" \
    --allow-root \
    --path=/var/www/html
fi

# 5) Create a sample post and a comment (idempotent)
if ! wp post list --post_type=post --field=post_title --allow-root --path=/var/www/html | grep -q "^Hello from Inception$"; then
  POST_ID=$(wp post create --post_title="Hello from Inception" --post_content="Auto-created during first boot." --post_status=publish --porcelain --allow-root --path=/var/www/html)
  echo "[wp] Created post ID ${POST_ID}"

  # add a comment by the second user if present, else anonymous
  if [ -n "${SECOND_USER}" ]; then
    wp comment create --comment_post_ID="${POST_ID}" --comment_content="Auto-comment by ${SECOND_USER} 🚀" --comment_author="${SECOND_USER}" --allow-root --path=/var/www/html >/dev/null
  else
    wp comment create --comment_post_ID="${POST_ID}" --comment_content="Auto-comment 🚀" --comment_author="inception-bot" --allow-root --path=/var/www/html >/dev/null
  fi
fi

exec "$@"
