#!/bin/bash
#
# Runs INSIDE a registry.redhat.io/ubi9/ubi container (see hack/rpm-lock.sh).
# Registers the container with RHSM, enables the RHEL CDN repos, and uses
# rpm-lockfile-prototype to regenerate .konflux/rpms.lock.yaml for every arch
# listed in .konflux/rpms.in.yaml.
#
# Modeled on openshift/lvm-operator's release/hack/generate-rpm-lock.sh.
set -euo pipefail
set -x

# Register the container with RHSM so we can reach the RHEL CDN repos.
subscription-manager clean || true
subscription-manager register --activationkey="${RHSM_ACTIVATION_KEY}" --org="${RHSM_ORG}"

arch="$(uname -m)"

# Activate the binary + source repos for BaseOS and AppStream.
dnf config-manager \
    --enable "rhel-9-for-${arch}-appstream-rpms" \
    --enable "rhel-9-for-${arch}-appstream-source-rpms" \
    --enable "rhel-9-for-${arch}-baseos-rpms" \
    --enable "rhel-9-for-${arch}-baseos-source-rpms"

# Install the resolver (same tool Konflux/cachi2 uses).
dnf install -y pip skopeo
pip install https://github.com/konflux-ci/rpm-lockfile-prototype/archive/refs/tags/v0.18.0.tar.gz

cd .konflux

# Expose the entitlement cert/key to DNF as $SSL_CLIENT_KEY / $SSL_CLIENT_CERT,
# which the repo definitions in rpms.in.yaml reference.
keydir="/etc/pki/entitlement"
keyfile="$(ls "${keydir}" | grep -- '-key')"
export DNF_VAR_SSL_CLIENT_KEY="${keydir}/${keyfile}"
export DNF_VAR_SSL_CLIENT_CERT="${keydir}/${keyfile//-key}"

# Resolve for all arches listed in rpms.in.yaml. Base image is read from
# konflux.Dockerfile via the `context.containerfile` setting in rpms.in.yaml.
rpm-lockfile-prototype --outfile=rpms.lock.yaml rpms.in.yaml
