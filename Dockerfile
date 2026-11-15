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
    sh /tmp/jdk.sh 17 "jdk-17.0.21%2B9" 17.0.21_9 \
      8b9b611d917e3dfd8419d3566b5949226f69b052fed7e109c1368add1dfe8711 \
      3e4eca7ead088f080af1476007decf010a240a1eb4e1e78c54fa32fbcc347084
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 21 "jdk-21.0.13%2B9" 21.0.13_9 \
      d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c \
      e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 25 "jdk-25.0.5%2B8" 25.0.5_8 \
      68982529869257d0ee6b824ec5aa270ff8b118bb438670da0b97ebdab178d7fb \
      bb5b2ded252f21c6090cf780b0a408ad0d83bbb557e702955643557f13231880
RUN --mount=type=bind,source=scripts/jdk.sh,target=/tmp/jdk.sh \
    sh /tmp/jdk.sh 26 "jdk-26.0.2.1%2B1" 26.0.2.1_1 \
      451c12e68747bcfa2fb5a2c16b00483fedb9fa6d77bc962d30957f76ac17044d \
      9f6ad9856a7dd880061adaf88db3c4da0642113d59b7960a892f0e551c0c948c

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
