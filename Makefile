OCIORG                    ?= quay.io/lvh-images
LVH                       ?= $(OCIORG)/lvh
ROOT_BUILDER              ?= $(OCIORG)/root-builder
ROOT_IMAGES               ?= $(OCIORG)/root-images
KERNEL_BUILDER            ?= $(OCIORG)/kernel-builder
KERNEL_IMAGES             ?= $(OCIORG)/kernel-images
KIND_IMAGES               ?= $(OCIORG)/kind
COMPLEXITY_TEST_IMAGES    ?= $(OCIORG)/complexity-test

KERNEL_BUILDER_TAG        ?= main
ROOT_BUILDER_TAG          ?= main
ROOT_IMAGES_TAG           ?= main
KERNEL_VERSIONS           ?= 4.19 5.4 5.10 5.15 6.1 bpf-next

DOCKER ?= docker
export DOCKER_BUILDKIT = 1

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  kernel-builder:   build root kernel builder images"
	@echo "  root-builder:     build root fs builder images"
	@echo "  root-images:      build root fs images"
	@echo "  kernel-images:    build kernel images"
	@echo "  kind:             build root kind images"
	@echo "  complexity-test:  build root complexity-test images"

.PHONY: kernel-builder
kernel-builder:
	$(DOCKER) build -f dockerfiles/kernel-builder -t $(KERNEL_BUILDER):$(KERNEL_BUILDER_TAG) .

.PHONY: root-builder
root-builder:
	$(DOCKER) build -f dockerfiles/root-builder -t $(ROOT_BUILDER):$(ROOT_BUILDER_TAG) .

.PHONY: root-images
root-images: root-builder
	$(DOCKER) build -f dockerfiles/root-images \
		--build-arg ROOT_BUILDER_TAG=latest \
		-t $(ROOT_IMAGES):$(ROOT_IMAGES_TAG)  .

.PHONY: kernel-images
kernel-images: kernel-builder
	for v in $(KERNEL_VERSIONS) ; do \
		$(DOCKER) build --no-cache \
			--build-arg KERNEL_BUILDER_TAG=$(KERNEL_BUILDER_TAG) \
			--build-arg KERNEL_VER=$$v \
			-f dockerfiles/kernel-images -t $(KERNEL_IMAGES):$$v . ; \
	done

.PHONY: kind
kind: kernel-images root-images
	for v in $(KERNEL_VERSIONS) ; do \
		 $(DOCKER) build --no-cache \
			--build-arg KERNEL_VER=$$v \
			--build-arg KERNEL_IMAGE_TAG=$$v-${KERNEL_BUILDER_TAG} \
			--build-arg ROOT_BUILDER_TAG=$(ROOT_BUILDER_TAG) \
			--build-arg ROOT_IMAGES_TAG=$(ROOT_IMAGES_TAG) \
			-f dockerfiles/kind-images -t $(KIND_IMAGES):$$v . ; \
	done

.PHONY: complexity-test
complexity-test: kernel-images root-images
	for v in $(KERNEL_VERSIONS) ; do \
		 $(DOCKER) build --no-cache \
			--build-arg KERNEL_VER=$$v \
			--build-arg KERNEL_IMAGE_TAG=$$v-${KERNEL_BUILDER_TAG} \
			--build-arg ROOT_BUILDER_TAG=$(ROOT_BUILDER_TAG)_ \
			--build-arg ROOT_IMAGES_TAG=$(ROOT_IMAGES_TAG) \
			-f dockerfiles/complexity-test-images -t $(COMPLEXITY_TEST_IMAGES):$$v . ; \
	done
