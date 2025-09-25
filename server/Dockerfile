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

RUN apk add --no-cache vips libheif

COPY --from=builder /usr/local/bin/app /usr/local/bin/app
COPY --from=builder /usr/src/app/lib /app/lib
COPY --from=builder /usr/src/app/static /app/static

ENV STATIC_DIR=/app/static
ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb

EXPOSE $PORT

CMD ["app"]
