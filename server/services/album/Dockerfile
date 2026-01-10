FROM golang:1.24.1-bullseye AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/album /usr/src/app/services/album

FROM debian:bookworm-slim

WORKDIR /app

RUN apt update && apt install -y --no-install-recommends ca-certificates

COPY --from=builder /usr/local/bin/album /usr/local/bin/album

RUN chmod +x /usr/local/bin/album

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/album" ]
