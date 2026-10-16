#!/usr/bin/env bash
#
# Regenerate .konflux/rpms.lock.yaml for the base image pinned in
# .konflux/konflux.Dockerfile.
#
# This runs the regeneration INSIDE a RHEL ubi9 container that registers itself
# with Red Hat Subscription Manager via an activation key, so it works on any
# host with podman — no host entitlements required.
#
# Modeled on openshift/lvm-operator's `make rpm-lock`.
#
# Requirements:
#   - podman
#   - a registry.redhat.io pull secret (podman/docker login registry.redhat.io)
#   - RHSM Org ID + activation key
#       https://console.redhat.com/insights/connector/activation-keys
#
# Usage:
#   export RHSM_ORG="<your-org-id>"
#   export RHSM_ACTIVATION_KEY="<your-activation-key>"
#   # optional, defaults to the podman auth file:
#   # export AUTH_FILE="$HOME/.docker/config.json"
#   hack/rpm-lock.sh
#
set -euo pipefail

: "${RHSM_ORG:?set RHSM_ORG (Red Hat Subscription Manager Org ID)}"
: "${RHSM_ACTIVATION_KEY:?set RHSM_ACTIVATION_KEY (RHSM activation key)}"

AUTH_FILE="${AUTH_FILE:-${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/containers/auth.json}"
UBI_IMAGE="${UBI_IMAGE:-registry.redhat.io/ubi9/ubi:9.6}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "${AUTH_FILE}" ]]; then
  echo "error: registry auth file not found at ${AUTH_FILE}" >&2
  echo "       run 'podman login registry.redhat.io' or set AUTH_FILE=/path/to/config.json" >&2
  exit 1
fi

echo "Using registry auth: ${AUTH_FILE}"
echo "Regenerating .konflux/rpms.lock.yaml inside ${UBI_IMAGE} (all arches, takes a few minutes)..."

podman run --rm -it \
  -v "${REPO_ROOT}:/source:z" \
  -v "${AUTH_FILE}:/.dockerconfig.json:z" \
  --env "REGISTRY_AUTH_FILE=/.dockerconfig.json" \
  --env "RHSM_ACTIVATION_KEY=${RHSM_ACTIVATION_KEY}" \
  --env "RHSM_ORG=${RHSM_ORG}" \
  --workdir /source \
  "${UBI_IMAGE}" ./hack/generate-rpm-lock.sh

echo
echo "Done. Review the changes, then commit the Dockerfile + lockfile together:"
echo "    git add .konflux/konflux.Dockerfile .konflux/rpms.lock.yaml"
echo "    git commit -s -m \"chore(deps): bump rhel-minimal base image and regenerate RPM lockfile\""
