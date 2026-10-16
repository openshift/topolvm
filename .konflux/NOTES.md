# Konflux builds for release-4.15

TopoLVM builds the `lvms4/topolvm-rhel9` image with the RHEL 9 Go 1.21
builder. The operator, bundle, and catalog live in `openshift/lvm-operator`.

The push and pull request pipelines use the shared multi-architecture pipeline.
Their triggers cover the source directories on this branch. Go dependencies
come from Konflux gomod prefetch, and the build uses `-mod=readonly`.
The former vendor tree matched `go mod vendor` and has been removed.

## RPM lockfile

`rpms.in.yaml` resolves RHEL 9 BaseOS and AppStream binary and source RPMs
against the runtime base image in `konflux.Dockerfile`. The lock covers
`aarch64`, `x86_64`, `s390x`, and `ppc64le`.

To generate it, install Podman and provide Red Hat Subscription Manager
credentials and a registry auth file with access to `registry.redhat.io`:

```bash
export RHSM_ORG="<YOUR_RHSM_ORG>"
export RHSM_ACTIVATION_KEY="<YOUR_RHSM_ACTIVATION_KEY>"
export AUTH_FILE="/path/to/your/docker/config.json"
make -f .konflux/konflux.make rpm-lock
```

The helper runs as root inside UBI 9 and uses rpm-lockfile-prototype v0.18.0.
Review and commit the Dockerfile and lockfile together when changing the base.
