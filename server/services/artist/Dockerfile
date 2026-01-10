FROM golang:1.24.1-bullseye AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/artist /usr/src/app/services/artist

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /usr/local/bin/artist /usr/local/bin/artist

RUN chmod +x /usr/local/bin/artist

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/artist" ]
