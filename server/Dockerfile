FROM golang:1.24.1-bullseye AS builder

RUN apt update && apt install -y --no-install-recommends libvips42 libvips-dev libheif-dev libexif-dev gcc
WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=1
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/app .

FROM debian:bookworm-slim

WORKDIR /app

RUN apt update && apt install -y --no-install-recommends \
    libvips42 \
    libheif-dev \
    ca-certificates \
    wget \
    tar \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/app /usr/local/bin/app
COPY --from=builder /usr/src/app/static /app/static
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb
ENV STATIC_DIR=/app/static

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
