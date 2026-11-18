ARG GO_VERSION=1.24.13
ARG ALPINE_VERSION=3.22

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder

RUN apk add --no-cache alpine-sdk git && \
    mkdir -p /api
WORKDIR /api

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o ./app ./main.go

FROM alpine:${ALPINE_VERSION}

LABEL org.opencontainers.image.source="https://github.com/SimplicityGuy/podgrab"

ENV CONFIG=/config
ENV DATA=/assets
ENV UID=998
ENV PID=100
ENV GIN_MODE=release
VOLUME ["/config", "/assets"]
RUN apk add --no-cache ca-certificates
RUN mkdir -p /config; \
    mkdir -p /assets; \
    mkdir -p /api

RUN chmod 777 /config; \
    chmod 777 /assets

WORKDIR /api
COPY --from=builder /api/app .
COPY client ./client
COPY webassets ./webassets

EXPOSE 8080

ENTRYPOINT ["./app"]
