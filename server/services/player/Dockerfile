FROM golang:1.25-alpine AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/player /usr/src/app/services/player

FROM debian:bookworm-slim

WORKDIR /app

RUN apt update && apt install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/player /usr/local/bin/player
COPY --from=builder /usr/src/app/services/player/static /app/static

ENV STATIC_DIR=/app/static

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/player" ]
