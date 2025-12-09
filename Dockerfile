FROM golang:1.23-bookworm AS builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

ARG TARGETARCH=arm64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -mod=mod -o dockercraft .

FROM alpine:3.19 AS docker-cli
ARG DOCKER_VERSION=25.0.3
ARG TARGETARCH=arm64
RUN apk add --no-cache wget tar && \
  if [ "$TARGETARCH" = "amd64" ]; then ARCH="x86_64"; else ARCH="aarch64"; fi && \
  wget -qO- https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz | \
  tar -xvz --strip-components=1 -C /bin

FROM alpine:3.19 AS cuberite-downloader
WORKDIR /srv
ARG TARGETARCH=arm64
RUN apk add --no-cache wget tar git && \
  if [ "$TARGETARCH" = "amd64" ]; then ARCH="x86_64"; else ARCH="aarch64"; fi && \
  wget -qO- "https://download.cuberite.org/linux-${ARCH}/Cuberite.tar.gz" | \
  tar -xzf - && \
  mkdir -p /srv/Server/Plugins && \
  git clone https://github.com/cuberite/Core.git /srv/Server/Plugins/Core && \
  git clone https://github.com/cuberite/TransAPI.git /srv/Server/Plugins/TransAPI && \
  git clone https://github.com/cuberite/ChatLog.git /srv/Server/Plugins/ChatLog && \
  wget -O /srv/Server/Plugins/InfoReg.lua https://raw.githubusercontent.com/cuberite/Cuberite/master/Server/Plugins/InfoReg.lua && \
  mv webadmin Server/ && \
  mv *.txt Server/ && \
  mv *.ini Server/ && \
  mv Protocol Server/ && \
  mv Prefabs Server/

FROM debian:trixie-slim

RUN apt-get update && \
  apt-get install -y ca-certificates && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/dockercraft /bin/dockercraft
COPY --from=docker-cli /bin/docker /bin/docker
COPY --from=cuberite-downloader /srv /srv

COPY ./config /srv/Server
COPY ./docs/img/logo64x64.png /srv/Server/favicon.png
COPY ./Docker /srv/Server/Plugins/Docker

EXPOSE 25565

WORKDIR /srv/Server

ENTRYPOINT ["/srv/Server/start.sh"]
