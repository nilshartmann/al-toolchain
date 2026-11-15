# al-toolchain

## Contents

- Temurin 17, 21, 25 and 26 in `/opt/java/<n>`, JDK 25 is the default (`JAVA_HOME` and `PATH`),
- Maven 3.9 as `mvn`,
- Node 24 with npm and corepack (pnpm and Yarn in the version named in `packageManager`),
- the locales `de_DE.UTF-8` and `en_US.UTF-8` and the time zone data,
- the libraries Chromium needs for Playwright. The project downloads the browser itself.

Every download has a fixed version and a fixed checksum for each architecture.

## Build

The action `.github/workflows/build.yml` builds on a push to `main` that changes the image, and by hand through "Run workflow". It
checks each architecture with `scripts/check.sh` and prints the digest of the image at the end.
