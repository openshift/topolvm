SHELL := /bin/bash

AUTH_FILE ?= $(XDG_RUNTIME_DIR)/containers/auth.json
export RHSM_ORG RHSM_ACTIVATION_KEY

.PHONY: rpm-lock
rpm-lock: rhsm-keys
	podman run --rm -it --user 0:0 --authfile "$(AUTH_FILE)" \
	-v "$(CURDIR):/source:z" \
	-v "$(AUTH_FILE):/.dockerconfig.json:z" \
	--env REGISTRY_AUTH_FILE=/.dockerconfig.json \
	--env RHSM_ACTIVATION_KEY \
	--env RHSM_ORG \
	--env SMDEV_CONTAINER_OFF=1 \
	--workdir /source \
	registry.redhat.io/ubi9/ubi:latest ./.konflux/generate-rpm-lock.sh

.PHONY: rhsm-keys
rhsm-keys:
ifndef RHSM_ACTIVATION_KEY
	$(error environment variable RHSM_ACTIVATION_KEY is required)
endif
ifndef RHSM_ORG
	$(error environment variable RHSM_ORG is required)
endif

	@test -f "$(AUTH_FILE)" || { echo "AUTH_FILE must point to a registry auth file" >&2; exit 1; }
