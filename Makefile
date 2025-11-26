.PHONY: all test test-local install-deps lint fmt vet build serve

REPO_NAME = dockercraft
REPO_OWNER = docker
PKG_NAME = github.com/${REPO_OWNER}/${REPO_NAME}
IMAGE = golang:1.8
IMAGE_NAME = dockercraft
CONTAINER_NAME = dockercraft
PACKAGES=$(shell go list ./... | grep -v vendor)

all: test

test-local: install-deps fmt lint vet
	@echo "+ $@"
	@go test -v .

test:
	@docker run -v ${shell pwd}:/go/src/${PKG_NAME} -w /go/src/${PKG_NAME} ${IMAGE} make test-local

install-deps:
	@echo "+ $@"
	@go get -u github.com/golang/lint/golint

lint:
	@echo "+ $@"
	@test -z "$$(golint $(PACKAGES) | tee /dev/stderr)"

fmt:
	@echo "+ $@"
	@test -z "$$(gofmt -s -l *.go | tee /dev/stderr)"

vet:
	@echo "+ $@"
	go vet $(PACKAGES)

build:
	@echo "+ $@"
	@docker build -t ${IMAGE_NAME} .

serve: DOCKER_RM = --rm
serve serve-no-rm:
	@docker run -it -d ${DOCKER_RM} \
		--name ${CONTAINER_NAME} \
		-p 25565:25565 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		${IMAGE_NAME}

logs:
	@docker logs ${CONTAINER_NAME}

delete:
	@docker rm -f ${CONTAINER_NAME}

clean:
	@docker rmi ${IMAGE_NAME}