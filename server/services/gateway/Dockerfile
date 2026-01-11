FROM golang:1.24.1-bullseye AS builder

WORKDIR /usr/src/app
RUN apt update && apt install -y --no-install-recommends libvips42 libvips-dev libheif-dev libexif-dev gcc

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=1
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/gateway /usr/src/app/services/gateway

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

COPY --from=builder /usr/local/bin/gateway /usr/local/bin/gateway
COPY --from=builder /usr/src/app/services/gateway/static /app/static

RUN chmod +x /usr/local/bin/gateway

ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb
ENV STATIC_DIR=/app/static
ENV GO_ENV=prod

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/gateway" ]
