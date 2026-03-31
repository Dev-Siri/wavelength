FROM golang:1.25-alpine AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/music /usr/src/app/services/music

FROM debian:bookworm-slim

WORKDIR /app

RUN apt update && apt install -y --no-install-recommends ca-certificates

COPY --from=builder /usr/local/bin/music /usr/local/bin/music

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/music" ]
