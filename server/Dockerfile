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

RUN apk add --no-cache vips libheif wget tar python3 ffmpeg

COPY --from=builder /usr/local/bin/app /usr/local/bin/app
COPY --from=builder /usr/src/app/static /app/static
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb
ENV YT_DLP_PATH=/app/lib/yt-dlp
ENV STATIC_DIR=/app/static

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
