# syntax=docker/dockerfile:1
#
# Toolchain on Ubuntu 24.04: JDKs, Maven, Node with npm and corepack and the system libraries Chromium
# needs for Playwright. It is meant as a base for other images and therefore has no entrypoint and no
# user of its own.
#
# Every download has a fixed version and a fixed SHA-256 (SHA-512 for Maven) for each architecture.

FROM ubuntu:24.04@sha256:2198e4c65076e9cb0b3d695219df667c0e3b0072da64ca3c2648aca17dcecaf5

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

# Basic tools and the libraries of headless Chromium. The browser itself is not part of the image:
# Playwright of a project needs exactly the revision of its own version and downloads it into
# PLAYWRIGHT_BROWSERS_PATH.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils locales tzdata \
      libnss3 libnspr4 libatk1.0-0t64 libatk-bridge2.0-0t64 libatspi2.0-0t64 libcups2t64 libdbus-1-3 \
      libdrm2 libgbm1 libglib2.0-0t64 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
      libpango-1.0-0 libcairo2 libasound2t64 fonts-liberation fonts-noto-color-emoji \
 && locale-gen de_DE.UTF-8 en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# Temurin JDKs under /opt/java/<major>. Arguments: major, tag of the release, version in the file name,
# SHA-256 for x64, SHA-256 for aarch64.
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 17 "jdk-17.0.21.1%2B2" 17.0.21.1_2 \
      0b0ac5eab6db6abaec68c9913bcddb31321e5da411c45073d520d9c125e6f7b4 \
      1d808f4b558e9de63d8ba3ead21ffc8b9de204894eff3c19d52c1480aa17cc58
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 21 "jdk-21.0.13.1%2B2" 21.0.13.1_2 \
      bb8a93f9ae6e7a693b2b721e85dbeff26ae1a77447985a8d7afcdd9c7cf6222e \
      8c72816a6b308842d5ed1f13e5826b69c567da4784f7238d7e800efa71fe54b1
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 25 "jdk-25.0.5.1%2B2" 25.0.5.1_2 \
      760f91b22c3efc9bd1b64ff950598231be82928cc807e30691a0e7a2995a62c0 \
      c37879e0d08eeb1baa69fcbb7758cd455b7b1c0ceab1e2a136ccb1713c530984
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 27 "jdk-27.0.1.1%2B4" 27.0.1.1_4 \
      005e57ee860978acfeeff1be2b30f770664fe2b941e9b803c61c76992086d107 \
      fc6986815165fc9506eb6a01ace00942f5c91c993102355ab01cea3e2de9736d

# Maven for projects without a wrapper. A wrapper downloads its own version.
ARG MAVEN_VERSION=3.9.16
ARG MAVEN_SHA512=831a8591fe20c8243b1dbe7d71e3244f31d1665b0804b2e825e38cbbe5ce0cafb8338851f90780735568773e0a6cd07bbec107cda0b896b008b861075358b6f6
RUN set -eu; \
    cd /tmp; \
    tarball="apache-maven-${MAVEN_VERSION}-bin.tar.gz"; \
    curl -fsSLO "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/${tarball}"; \
    echo "${MAVEN_SHA512}  ${tarball}" | sha512sum -c -; \
    mkdir -p /opt/maven; \
    tar -xzf "${tarball}" -C /opt/maven --strip-components=1; \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn; \
    rm -f "${tarball}"

# Node from the official tarball. pnpm and Yarn come through corepack in the version a project names in
# packageManager, downloaded from the registry of npm on first use.
ARG NODE_VERSION=24.22.2
ARG NODE_SHA256_X64=48cc0e21e048790e54c0cf5749c2725005313d652651c40b7a21feb9697aaf75
ARG NODE_SHA256_ARM64=eb187837a2230d4047161ac0be008584e16b46f726e9c9490ee35dc6b17d9ba8
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) arch=x64; sha="$NODE_SHA256_X64" ;; \
      arm64) arch=arm64; sha="$NODE_SHA256_ARM64" ;; \
      *) echo "Unsupported architecture: '$TARGETARCH'." >&2; exit 1 ;; \
    esac; \
    cd /tmp; \
    tarball="node-v${NODE_VERSION}-linux-${arch}.tar.xz"; \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/${tarball}"; \
    echo "${sha}  ${tarball}" | sha256sum -c -; \
    tar -xJf "${tarball}" -C /usr/local --strip-components=1 \
      --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' --exclude='*/README.md'; \
    rm -f "${tarball}"; \
    corepack enable

# JDK 25 is the default. Another one is chosen with JAVA_HOME and PATH.
ENV JAVA_HOME=/opt/java/25 \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    PATH=/opt/java/25/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LABEL org.opencontainers.image.source="https://github.com/nilshartmann/al-toolchain" \
      org.opencontainers.image.description="JDKs, Maven and Node on Ubuntu 24.04"
