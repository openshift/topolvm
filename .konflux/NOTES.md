# Konflux onboarding notes for release-4.13 (RHEL8)

This directory is a backport of the Konflux build scaffolding from `release-4.14`,
adapted for the RHEL8-based 4.13 stream. topolvm is the CSI/controller component of
LVM Storage; it builds a single container image (`lvms4/topolvm-rhel8` on 4.13), so
there is no bundle or catalog here — those live in `openshift/lvm-operator`.

## Why this is not a straight copy of release-4.14

LVMS 4.12 and 4.13 are **RHEL8**-based; 4.14 and later are **RHEL9**-based. The
published images confirm this: `lvms4/topolvm-rhel8` exists for 4.13 while
`lvms4/topolvm-rhel9` does not.

Differences from the 4.14 scaffolding:

* Base images are UBI8 and `openshift-golang-builder:rhel_8_1.20` (4.13 is `go 1.20`).
* `name` label is `lvms4/topolvm-rhel8` and the cpe label is `cpe:/a:redhat:lvms:4.13::el8`.
* `rpms.in.yaml` resolves against the el8 base image (`imagePattern`).
* **`release-4.13` does not vendor its dependencies, but `release-4.14` does.**
  The 4.14 Dockerfile builds with `-mod=vendor`; that would fail here, so this
  Dockerfile uses `-mod=readonly` and relies on the Konflux gomod prefetch declared
  in `prefetch-input`. The operator onboarding also replaces its vendor tree with module prefetch.
* The PipelineRun CEL triggers were rewritten for the 4.13 source layout: 4.14
  references `cmd/`, `internal/` and `test/`, none of which exist on 4.13. They now
  list the directories this branch actually builds from. This also fixes a
  parenthesis bug carried in the 4.14 expression, where `|| "pkg/***".pathChanged()`
  sat outside the closing paren and so was OR'd against the whole
  `event == "push" && target_branch == ...` guard rather than being part of the
  path list.

## RPM lockfile

`rpms.lock.yaml` includes RHEL 8 binary and source RPMs for `aarch64`, `x86_64`,
`s390x`, and `ppc64le`, matching `rpms.in.yaml`.

Generate the lockfile from this branch with the helper below. The inputs use
explicit RHEL 8 BaseOS and AppStream repositories and the pinned UBI 8 runtime
base image.

To generate it again, install Podman and provide Red Hat Subscription Manager
credentials plus a registry auth file with access to `registry.redhat.io`:

```bash
export RHSM_ORG="<YOUR_RHSM_ORG>"
export RHSM_ACTIVATION_KEY="<YOUR_RHSM_ACTIVATION_KEY>"
export AUTH_FILE="/path/to/your/docker/config.json"

# From the topolvm repo root:
make -f .konflux/konflux.make rpm-lock
```

The helper runs as root inside a UBI 9 container to use its Python and DNF tools.
The resolved packages and runtime base image remain RHEL 8. Generation covers all
four architectures and can take a few minutes.
