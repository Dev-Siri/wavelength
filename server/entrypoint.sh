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

if [ -n "$YOUTUBE_COOKIES_B64" ]; then
  echo "Decoding YouTube cookies from YOUTUBE_COOKIES_B64..."
  mkdir -p /app/secrets
  echo "$YOUTUBE_COOKIES_B64" | base64 -d > /app/secrets/youtube_cookies.txt
fi

# Run the Python yt-dlp server.
cd /app/internal/ytdlp_server
/usr/local/pypy3.11-v7.3.20-linux64/bin/pypy3 -m uvicorn main:app --host 0.0.0.0 --port 8000 &
# Run the Go application.
/usr/local/bin/app