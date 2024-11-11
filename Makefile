OCIORG                    ?= sebymiano
LVH                       ?= quay.io/lvh-images/lvh
ROOT_BUILDER              ?= $(OCIORG)/root-builder-ci
ROOT_IMAGES               ?= $(OCIORG)/root-images-ci
KERNEL_BUILDER            ?= $(OCIORG)/kernel-builder-ci
KERNEL_IMAGES             ?= $(OCIORG)/kernel-images-ci
PATHNET_IMAGES            ?= $(OCIORG)/lvh-pathnet

KERNEL_BUILDER_TAG        ?= main
ROOT_BUILDER_TAG          ?= main
ROOT_IMAGES_TAG           ?= main
KERNEL_VERSIONS           ?= 5.15 6.2 bpf-next

DOCKER ?= docker
export DOCKER_BUILDKIT = 1

# define empty DOCKER_BUILD_FLAGS
DOCKER_BUILD_FLAGS :=

# set USE_CACHE to false by default
USE_CACHE ?= false

# Check if variable USE_CACHE is set to false
ifeq ($(USE_CACHE),false)
	DOCKER_BUILD_FLAGS += --no-cache
endif

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	TARGET_ARCH ?= amd64
else ifeq ($(UNAME_M),aarch64)
	TARGET_ARCH ?= arm64
else
	TARGET_ARCH ?= amd64
endif

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  kernel-builder:   build root kernel builder images"
	@echo "  root-builder:     build root fs builder images"
	@echo "  root-images:      build root fs images"
	@echo "  kernel-images:    build kernel images"
	@echo "  pathnet:          build root pathnet images"

.PHONY: kernel-builder
kernel-builder:
	$(DOCKER) build --progress=plain -f dockerfiles/kernel-builder -t $(KERNEL_BUILDER):$(KERNEL_BUILDER_TAG) .

.PHONY: root-builder
root-builder:
	$(DOCKER) build -f dockerfiles/root-builder \
		--progress=plain \
		-t $(ROOT_BUILDER):$(ROOT_BUILDER_TAG) .

.PHONY: root-images
root-images: root-builder
	$(DOCKER) build -f dockerfiles/root-images \
		--progress=plain $(DOCKER_BUILD_FLAGS) \
		--build-arg ROOT_BUILDER_TAG=$(ROOT_BUILDER_TAG) \
		--build-arg ROOT_BUILDER_NAME=$(ROOT_BUILDER) \
		-t $(ROOT_IMAGES):$(ROOT_IMAGES_TAG)  .

.PHONY: kernel-images
kernel-images: kernel-builder
	for v in $(KERNEL_VERSIONS) ; do \
		$(DOCKER) build $(DOCKER_BUILD_FLAGS) \
			--progress=plain \
			--build-arg KERNEL_BUILDER_TAG=$(KERNEL_BUILDER_TAG) \
			--build-arg KERNEL_BUILDER_NAME=$(KERNEL_BUILDER) \
			--build-arg KERNEL_VER=$$v \
			--platform=linux/${TARGET_ARCH} \
			-f dockerfiles/kernel-images -t $(KERNEL_IMAGES):$$v . ; \
	done

.PHONY: pathnet
pathnet: kernel-images root-images
	for v in $(KERNEL_VERSIONS) ; do \
		 $(DOCKER) build $(DOCKER_BUILD_FLAGS) \
			--build-arg KERNEL_VER=$$v \
			--build-arg ROOT_IMAGES_NAME=$(ROOT_IMAGES) \
			--build-arg ROOT_IMAGES_TAG=$(ROOT_IMAGES_TAG) \
			--build-arg KERNEL_IMAGES_NAME=$(KERNEL_IMAGES) \
			--build-arg KERNEL_IMAGE_TAG=$$v \
			--build-arg ROOT_BUILDER_NAME=$(ROOT_BUILDER) \
			--build-arg ROOT_BUILDER_TAG=$(ROOT_BUILDER_TAG) \
			-f dockerfiles/pathnet-images -t $(PATHNET_IMAGES):$$v . ; \
	done

.PHONY: push
push: 
	for v in $(KERNEL_VERSIONS) ; do \
		 $(DOCKER) push $(PATHNET_IMAGES):$$v ; \
	done

.PHONY: systemd-workaround
systemd-workaround:
	$(DOCKER) rm systemd-workaround-builder || true
	$(DOCKER) run -v $(CURDIR)/systemd-workaround:/src:Z --name systemd-workaround-builder gcc:14 sh -c 'make -C /src'
	cp $(CURDIR)/systemd-workaround/systemd-pidfd-fix.so _data/bootstrap/
	$(DOCKER) rm systemd-workaround-builder
