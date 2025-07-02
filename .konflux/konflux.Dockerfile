FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_1.22 as builder
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM
ARG TOPOLVM_VERSION

WORKDIR /workspace

COPY api/ api/
COPY cmd/ cmd/
COPY internal/ internal/ 
COPY pkg/ pkg/
COPY Makefile go.mod go.sum constants.go version.go csi-sidecars.mk versions.mk ./

ENV CGO_ENABLED=1
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
ENV GOEXPERIMENT=strictfipsruntime

RUN go build -tags strictfipsruntime -o hypertopolvm -mod=mod -ldflags "-w -s -X github.com/topolvm/topolvm.Version=${TOPOLVM_VERSION}" ./cmd/hypertopolvm

FROM --platform=$TARGETPLATFORM registry.redhat.io/rhel9-4-els/rhel-minimal:9.4

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
LABEL name="lvms4/topolvm-rhel9"
LABEL version="${TOPOLVM_VERSION}"
LABEL description="LVM TopoLVM"
LABEL summary="The Topolvm CSI and controller."
LABEL io.k8s.display-name="LVM TopoLVM"
LABEL io.k8s.description="LVM Storage TopoLVM based on Red Hat Enterprise Linux 9 Image"
LABEL io.openshift.tags="lvms"
LABEL konflux.additional-tags="${VERSION_STREAM} v${TOPOLVM_VERSION}}"

ENTRYPOINT [ "/hypertopolvm" ]
