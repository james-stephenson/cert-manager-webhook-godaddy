OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

.DEFAULT_GOAL := build
.PHONY: verify test build clean rendered-manifest.yaml

verify:
	go test -v .

test: verify

build:
	bazel build --platforms=@io_bazel_rules_go//go/toolchain:linux_arm 

clean:
	rm -rf "$(OUT)"

rendered-manifest.yaml:
	helm template \
		--name-template godaddy-solver \
		--namespace cert-manager \
		deploy/cert-manager-webhook-godaddy > "$(OUT)/rendered-manifest.yaml"

