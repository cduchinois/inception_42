#!/bin/bash
set -euo pipefail
mkdir -p /var/cache/nginx /var/run
exec "$@"
