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
    ffmpeg \
    ca-certificates \
    wget \
    tar \
    bzip2 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.python.org/pypy/pypy3.11-v7.3.20-linux64.tar.bz2 -O /tmp/pypy.tar.bz2 \
    && tar -xjf /tmp/pypy.tar.bz2 -C /usr/local \
    && rm /tmp/pypy.tar.bz2
    
COPY --from=builder /usr/local/bin/app /usr/local/bin/app
COPY --from=builder /usr/src/app/static /app/static
COPY --from=builder /usr/src/app/internal /app/internal
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN /usr/local/pypy3.11-v7.3.20-linux64/bin/pypy3 -m ensurepip && \
    /usr/local/pypy3.11-v7.3.20-linux64/bin/pypy3 -m pip install -U pip && \
    /usr/local/pypy3.11-v7.3.20-linux64/bin/pypy3 -m pip install -r /app/internal/ytdlp_server/requirements.txt && \
    /usr/local/pypy3.11-v7.3.20-linux64/bin/pypy3 -m pip install -U yt-dlp
    
ENV GEOIP_MMDB_PATH=/app/lib/GeoLite2-Country.mmdb
ENV YT_DLP_SERVER_URL=http://localhost:8000
ENV STATIC_DIR=/app/static
ENV YT_COOKIE_PATH=/app/secrets/youtube_cookies.txt

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
