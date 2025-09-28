FROM golang:1.24.1-alpine AS builder
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

ARG MAXMIND_ACCOUNT_ID
ARG MAXMIND_LICENSE_KEY
ENV GEOIP_MMDB_URL=https://download.maxmind.com/geoip/databases/GeoLite2-Country/download?suffix=tar.gz
ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb

RUN mkdir -p /app/lib && \
    if [ -n "$MAXMIND_ACCOUNT_ID" ] && [ -n "$MAXMIND_LICENSE_KEY" ]; then \
      wget --content-disposition --user=$MAXMIND_ACCOUNT_ID --password=$MAXMIND_LICENSE_KEY -O /tmp/GeoLite2-Country.tar.gz "$GEOIP_MMDB_URL" && \
      tar --strip-components=1 -xvzf /tmp/GeoLite2-Country.tar.gz -C /app/lib && \
      rm -f /tmp/GeoLite2-Country.tar.gz; \
    fi

ENV STATIC_DIR=/app/static

EXPOSE 8080
CMD ["app"]