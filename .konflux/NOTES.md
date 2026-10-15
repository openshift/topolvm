# Konflux onboarding notes for release-4.12 (RHEL8)

This directory is a backport of the Konflux build scaffolding from `release-4.14`,
adapted for the RHEL8-based 4.12 stream. topolvm is the CSI/controller component of
LVM Storage; it builds a single container image (`lvms4/topolvm-rhel8` on 4.12), so
there is no bundle or catalog here — those live in `openshift/lvm-operator`.

## Why this is not a straight copy of release-4.14

LVMS 4.12 and 4.13 are **RHEL8**-based; 4.14 and later are **RHEL9**-based. The
published images confirm this: `lvms4/topolvm-rhel8` exists for 4.12 while
`lvms4/topolvm-rhel9` does not.

Differences from the 4.14 scaffolding:

* Base images are UBI8 and `openshift-golang-builder:rhel_8_1.20` (4.12 is `go 1.20`).
* `name` label is `lvms4/topolvm-rhel8` and the cpe label is `cpe:/a:redhat:lvms:4.12::el8`.
* `rpms.in.yaml` resolves against the el8 base image (`imagePattern`).
* **`release-4.12` does not vendor its dependencies, but `release-4.14` does.**
  The 4.14 Dockerfile builds with `-mod=vendor`; that would fail here, so this
  Dockerfile uses `-mod=readonly` and relies on the Konflux gomod prefetch declared
  in `prefetch-input`. (Note this is the opposite of `openshift/lvm-operator`, where
  4.12 *does* vendor and 4.14 does not.)
* The PipelineRun CEL triggers were rewritten for the 4.12 source layout: 4.14
  references `cmd/`, `internal/` and `test/`, none of which exist on 4.12. They now
  list the directories this branch actually builds from. This also fixes a
  parenthesis bug carried in the 4.14 expression, where `|| "pkg/***".pathChanged()`
  sat outside the closing paren and so was OR'd against the whole
  `event == "push" && target_branch == ...` guard rather than being part of the
  path list.

## TODO before the first Konflux build: generate `rpms.lock.yaml`

**`.konflux/rpms.lock.yaml` is intentionally NOT included in this change.**

It is an architecture- and content-specific lockfile that must be resolved against
the **el8** repositories. Generating it requires Red Hat Subscription Manager
credentials and a `registry.redhat.io` pull secret, neither of which were available
to the automation that produced this backport. Committing a lockfile resolved
against el9 content would produce an unbuildable or silently wrong image.

`rpms.in.yaml` reads its repository definitions from `./redhat.repo`, which is
produced on a subscribed host at lock time. Generate the lockfile with
`rpm-lockfile-prototype` from a subscribed RHEL8 host or container, for example:

```bash
rpm-lockfile-prototype --outfile=.konflux/rpms.lock.yaml .konflux/rpms.in.yaml
```

See `openshift/lvm-operator` `release/hack/generate-rpm-lock.md` on the matching
`release-4.12` branch for the full prerequisites and the containerised workflow.

Until the lockfile exists, the RPM `prefetch-input` step in
`.tekton/topolvm-push.yaml` and `.tekton/topolvm-pull-request.yaml` will fail.

### Also confirm before generating

The `arches:` list was carried over from 4.14 (`aarch64`, `x86_64`, `s390x`,
`ppc64le`). It was not possible to verify from the build environment which
architectures LVMS 4.12 actually shipped, because the registry mirror used for
inspection down-converts manifest lists to single-arch schema-v1 manifests. Please
confirm the 4.12 arch set and trim the list if 4.12 is not built for all four.
