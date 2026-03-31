FROM golang:1.25-alpine AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/collector /usr/src/app/services/collector

FROM debian:bookworm-slim

WORKDIR /app

RUN apt update && apt install -y --no-install-recommends python3 ffmpeg ca-certificates wget unzip

RUN wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
  chmod +x /usr/local/bin/yt-dlp && yt-dlp -U

RUN cd /usr/local/bin && \
    wget https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip && \
    unzip deno-x86_64-unknown-linux-gnu.zip && \
    rm deno-x86_64-unknown-linux-gnu.zip && \
    chmod +x deno && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/collector /usr/local/bin/collector

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/collector" ]
