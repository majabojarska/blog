all: serve

REPO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: serve
serve:
	 docker run --rm --name blog --network host -v $(REPO_ROOT):/blog ghcr.io/getzola/zola:v0.21.0 --root /blog serve
