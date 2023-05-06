MAKEFLAGS += -s
# No, we don't want builtin rules.
MAKEFLAGS += --no-builtin-rules
# Get some warnings about undefined variables
MAKEFLAGS += --warn-undefined-variables
# Get rid of .PHONY everywhere.
MAKEFLAGS += --always-make
# Use bash explicitly
SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset

# All supported platforms for container image distribution
IMAGE_PLATFORMS := linux/amd64 linux/i386 linux/arm64
# Container image repositories to push to
IMAGE_REPOS     := ghcr.io/charlie0129 docker.io/charlie0129
# Container image name
IMAGE_NAME      := bupt-net-login
# Container image tag
IMAGE_TAG       ?= latest
# Full Docker image name
IMAGE_REPO_TAGS ?= $(addsuffix /$(IMAGE_NAME):$(IMAGE_TAG),$(IMAGE_REPOS))

container:
	docker build $(addprefix -t ,$(IMAGE_REPO_TAGS)) .

BUILDX_PLATFORMS := $(shell echo "$(IMAGE_PLATFORMS)" | sed 's/ /,/g')
container-build-push:
	docker buildx build --push           \
	    --platform "$(BUILDX_PLATFORMS)" \
	    $(addprefix -t ,$(IMAGE_REPO_TAGS)) .

install:
	bash install.sh

