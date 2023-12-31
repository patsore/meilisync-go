# Dockerfile.distroless
FROM golang:1.20-bullseye as base

RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid 65532 \
  small-user

WORKDIR $GOPATH/src/meilisync-go/app/

COPY . .

RUN go mod download
RUN go mod verify

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -gcflags="all=-N -l" -o /main .

FROM ubuntu:22.04

COPY --from=base /main .
RUN apt-get update
RUN apt-get install -y mysql-client
CMD ["./main"]
