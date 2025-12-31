#!/bin/sh
set -e

GEOIP_MMDB_URL="https://download.maxmind.com/geoip/databases/GeoLite2-Country/download?suffix=tar.gz"

# Download GeoLite DB at runtime if credentials provided.
if [ -n "$MAXMIND_ACCOUNT_ID" ] && [ -n "$MAXMIND_LICENSE_KEY" ]; then
  echo "Downloading GeoLite database..."
  mkdir -p /app/lib
  wget --content-disposition \
    --user="$MAXMIND_ACCOUNT_ID" \
    --password="$MAXMIND_LICENSE_KEY" \
    -O /tmp/GeoLite2-Country.tar.gz "$GEOIP_MMDB_URL"
  tar --strip-components=1 -xvzf /tmp/GeoLite2-Country.tar.gz -C /app/lib
  rm -f /tmp/GeoLite2-Country.tar.gz
fi

# Run the Go application.
exec /usr/local/bin/gateway
