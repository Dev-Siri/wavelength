#!/bin/sh
set -e

GEOIP_MMDB_URL="https://download.maxmind.com/geoip/databases/GeoLite2-Country/download?suffix=tar.gz"
YT_DLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"

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

echo "Downloading yt-dlp..."
mkdir -p /app/lib
wget --content-disposition \
  -O /app/lib/yt-dlp "$YT_DLP_URL"
chmod +x /app/lib/yt-dlp

if [ -n "$YOUTUBE_COOKIES_B64" ]; then
  echo "Decoding YouTube cookies from YOUTUBE_COOKIES_B64..."
  mkdir -p /app/secrets
  echo "$YOUTUBE_COOKIES_B64" | base64 -d > /app/secrets/youtube_cookies.txt
fi

# Run the Go application.
/usr/local/bin/app