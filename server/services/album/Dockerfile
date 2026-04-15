FROM golang:1.25-alpine AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /usr/local/bin/album /usr/src/app/services/album

FROM scratch

COPY --from=builder /usr/local/bin/album /album
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

USER 65532:65532

EXPOSE 8080

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

ENTRYPOINT [ "/album" ]
