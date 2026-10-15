#!/bin/bash
set -euo pipefail

# Disable container mode before registering with RHSM.
rm /etc/rhsm-host
subscription-manager clean
subscription-manager register --activationkey="${RHSM_ACTIVATION_KEY}" --org="${RHSM_ORG}"

# Use UBI 9 tools to resolve the RHEL 8 repositories in rpms.in.yaml.
dnf install -y python3 python3-pip python3-dnf skopeo rpm
python3 -m pip install https://github.com/konflux-ci/rpm-lockfile-prototype/archive/refs/heads/main.zip

keyfiles=(/etc/pki/entitlement/*-key.pem)
if [[ ${#keyfiles[@]} -ne 1 || ! -f "${keyfiles[0]}" ]]; then
    echo "Expected one RHSM entitlement key in /etc/pki/entitlement" >&2
    exit 1
fi

export DNF_VAR_SSL_CLIENT_KEY="${keyfiles[0]}"
export DNF_VAR_SSL_CLIENT_CERT="${keyfiles[0]%-key.pem}.pem"

cd .konflux
rpm-lockfile-prototype --outfile=rpms.lock.yaml rpms.in.yaml
