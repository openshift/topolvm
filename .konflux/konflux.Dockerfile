FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_8_1.20 as builder
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM
ARG TOPOLVM_VERSION

WORKDIR /workspace

COPY ./ ./

ENV CGO_ENABLED=1
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
ENV GOEXPERIMENT=strictfipsruntime

# NOTE: release-4.12 does not vendor its dependencies (release-4.14 does), so the
# build runs with -mod=readonly and relies on the Konflux gomod prefetch
# (prefetch-input in .tekton/topolvm-*.yaml) to populate the module cache.
RUN go build -tags strictfipsruntime -o hypertopolvm -mod=readonly -ldflags "-w -s -X github.com/topolvm/topolvm.Version=${TOPOLVM_VERSION}" ./pkg/hypertopolvm

FROM --platform=$TARGETPLATFORM registry.redhat.io/ubi8/ubi-minimal@sha256:8de6d48ae7b421bca02fc402543eb69b2acb3dcadf18c0287d509eeea08f6fb2

ARG MAINTAINER
ARG TOPOLVM_VERSION
ARG VERSION_STREAM

RUN microdnf update -y && \
    microdnf install -y util-linux xfsprogs e2fsprogs && \
    microdnf clean all

COPY --from=builder /workspace/hypertopolvm /hypertopolvm

RUN ln -s hypertopolvm /lvmd \
    && ln -s hypertopolvm /topolvm-scheduler \
    && ln -s hypertopolvm /topolvm-node \
    && ln -s hypertopolvm /topolvm-controller

RUN mkdir /licenses
COPY LICENSE /licenses

USER 65532:65532

LABEL maintainer="${MAINTAINER}"
LABEL com.redhat.component="topolvm-container"
LABEL com.redhat.cpe="cpe:/a:redhat:lvms:4.12::el8"
LABEL name="lvms4/topolvm-rhel8"
LABEL version="${TOPOLVM_VERSION}"
LABEL description="LVM TopoLVM"
LABEL summary="The Topolvm CSI and controller."
LABEL io.k8s.display-name="LVM TopoLVM"
LABEL io.k8s.description="LVM Storage TopoLVM based on Red Hat Enterprise Linux 8 Image"
LABEL io.openshift.tags="lvms"
LABEL konflux.additional-tags="${VERSION_STREAM} v${TOPOLVM_VERSION}"

ENTRYPOINT [ "/hypertopolvm" ]
