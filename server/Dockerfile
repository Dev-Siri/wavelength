FROM golang:1.24.1-alpine AS builder

# Go server uses bimg which depends on vips for image processing.
RUN apk add --no-cache vips vips-dev libheif-dev libexif-dev gcc musl-dev

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=1
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/app .

FROM alpine:3.20
WORKDIR /app

RUN apk add --no-cache vips libheif wget tar

COPY --from=builder /usr/local/bin/app /usr/local/bin/app
COPY --from=builder /usr/src/app/static /app/static

ENV GEOIP_MMDB_URL=https://download.maxmind.com/geoip/databases/GeoLite2-Country/download?suffix=tar.gz
ENV MAXMIND_ACCOUNT_ID=""
ENV MAXMIND_LICENSE_KEY=""

RUN mkdir -p /app/lib
ENV STATIC_DIR=/app/static
ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb

# At container start, download & extract the GeoLite2 DB if it does not already exist.
ENTRYPOINT ["/bin/sh", "-c", "if [ ! -f \"$GEOIP_MMDB_PATH\" ]; then \n  if [ -z \"$MAXMIND_ACCOUNT_ID\" ] || [ -z \"$MAXMIND_LICENSE_KEY\" ]; then \n    echo 'ERROR: MAXMIND_ACCOUNT_ID or MAXMIND_LICENSE_KEY not set (set them as secrets/env vars in your host).'; \n    exit 1; \n  fi; \n  echo 'Downloading GeoLite2 database...'; \n  wget --content-disposition --user=$MAXMIND_ACCOUNT_ID --password=$MAXMIND_LICENSE_KEY -O /tmp/GeoLite2-Country.tar.gz \"$GEOIP_MMDB_URL\" || { echo 'Download failed'; exit 1; }; \n  tar --strip-components=1 -xvzf /tmp/GeoLite2-Country.tar.gz -C /app/lib || { echo 'Extraction failed'; exit 1; }; \n  rm -f /tmp/GeoLite2-Country.tar.gz; \nfi; \nexec app"]

EXPOSE $PORT

CMD ["app"]
