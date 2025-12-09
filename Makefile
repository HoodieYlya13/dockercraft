.PHONY: all test test-local install-deps lint fmt vet build serve

REPO_NAME = dockercraft
REPO_OWNER = docker
PKG_NAME = github.com/${REPO_OWNER}/${REPO_NAME}
IMAGE = golang:1.23
IMAGE_NAME = dockercraft
CONTAINER_NAME = dockercraft
PACKAGES=$(shell go list ./... | grep -v vendor)

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	TARGETARCH ?= amd64
else ifeq ($(UNAME_M),aarch64)
	TARGETARCH ?= arm64
else ifeq ($(UNAME_M),arm64)
	TARGETARCH ?= arm64
else
	TARGETARCH ?= amd64
endif

all: test

test-local: install-deps fmt lint vet
	@echo "+ $@"
	@go test -v .

test:
	@docker run -v ${shell pwd}:/go/src/${PKG_NAME} -w /go/src/${PKG_NAME} ${IMAGE} make test-local

install-deps:
	@echo "+ $@"
	@echo "No local dependencies needed for Docker-based linting."

lint:
	@echo "+ $@"
	@docker run --rm -e CGO_ENABLED=0 -e GOTOOLCHAIN=local -v $$(pwd):/app -w /app golangci/golangci-lint:v1.61.0 /bin/sh -c "go get golang.org/x/time@v0.5.0 && go get go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp@v0.49.0 && go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp@v1.24.0 && go get golang.org/x/sys@v0.28.0 && go get go.opentelemetry.io/otel@v1.30.0 && go mod tidy && go build -v ./... && golangci-lint run -v"

fmt:
	@echo "+ $@"
	@test -z "$$(gofmt -s -l *.go | tee /dev/stderr)"

vet:
	@echo "+ $@"
	go vet $(PACKAGES)

build:
	@echo "+ $@"
	@echo "Building for $(TARGETARCH)"
	@docker build --build-arg TARGETARCH=$(TARGETARCH) -t ${IMAGE_NAME} .

build-x86:
	@$(MAKE) build TARGETARCH=amd64

build-arm64:
	@$(MAKE) build TARGETARCH=arm64

serve: DOCKER_RM = --rm
serve serve-no-rm:
	@echo "+ $@"
	@docker run -it ${DOCKER_RM} \
		--name ${CONTAINER_NAME} \
		-p 25565:25565 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		${IMAGE_NAME} $(ARGS)

serve-ocean:
	@$(MAKE) serve ARGS="Ocean 50 63"

serve-frozen:
	@$(MAKE) serve ARGS="FrozenOcean 50 63 Ice"

serve-desert:
	@$(MAKE) serve ARGS="Desert 63 0 DeadBushes"

serve-forest:
	@$(MAKE) serve ARGS="Forest 63 0 Trees"

serve-jungle:
	@$(MAKE) serve ARGS="Jungle 63 0 Trees"

logs:
	@docker logs ${CONTAINER_NAME}

stop:
	@docker stop ${CONTAINER_NAME}

delete:
	@docker rm -f ${CONTAINER_NAME}

clean:
	@docker rmi ${IMAGE_NAME} || true
	@docker rm -f ${CONTAINER_NAME} || true