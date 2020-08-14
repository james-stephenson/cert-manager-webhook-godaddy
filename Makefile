OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

verify:
	go test -v .

build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
		--name-template godaddy-solver \
		--namespace cert-manager \
		deploy/cert-manager-webhook-godaddy > "$(OUT)/rendered-manifest.yaml"

