# al-toolchain

## Contents

- Temurin 17, 21, 25 and 27 in `/opt/java/<n>`, JDK 25 is the default (`JAVA_HOME` and `PATH`),
- Maven 3.9 as `mvn`,
- Node 24 with npm and corepack (pnpm and Yarn in the version named in `packageManager`),
- the locales `de_DE.UTF-8` and `en_US.UTF-8` and the time zone data,
- the libraries Chromium needs for Playwright. The project downloads the browser itself.

Every download has a fixed version and a fixed checksum for each architecture.

## al-toolchain-kubernetes

`ghcr.io/nilshartmann/al-toolchain-kubernetes` is the same toolchain with `kubectl` 1.35 and Helm 4 in `/usr/local/bin`. It is the
stage `kubernetes` of the Dockerfile and is built from the same commit as `al-toolchain`. There is no cluster in the image and no k3d.

## JDK 26 removed

JDK 26 has reached its end of life and gets no fix for CVE-2026-114938 ("Java4Shell"). It is therefore no longer part of the
image. Migrate to JDK 27. The last image with JDK 26 is tagged `sha-7310b73f909c`.

## Build

The action `.github/workflows/build.yml` builds on a push to `main` that changes the image, and by hand through "Run workflow". It
builds both images, checks each architecture with `scripts/check.sh` (the image with Kubernetes also with
`scripts/check-kubernetes.sh`) and prints both digests at the end.
