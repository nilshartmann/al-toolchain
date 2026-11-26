# al-toolchain

## Contents

- Temurin 17, 21, 25, 26 and 27 in `/opt/java/<n>`, JDK 25 is the default (`JAVA_HOME` and `PATH`),
- Maven 3.9 as `mvn`,
- Node 24 with npm and corepack (pnpm and Yarn in the version named in `packageManager`),
- the locales `de_DE.UTF-8` and `en_US.UTF-8` and the time zone data,
- the libraries Chromium needs for Playwright. The project downloads the browser itself.

Every download has a fixed version and a fixed checksum for each architecture.

## JDK 26 is affected by CVE-2026-114938

JDK 26 has reached its end of life and gets no fix for CVE-2026-114938 ("Java4Shell"). Migrate to JDK 27. The next version of
this image no longer contains JDK 26. JDK 17, 21, 25 and 27 are included in versions with the fix (17.0.21.1, 21.0.13.1, 25.0.5.1
and 27.0.1.1).

## Build

The action `.github/workflows/build.yml` builds on a push to `main` that changes the image, and by hand through "Run workflow". It
checks each architecture with `scripts/check.sh` and prints the digest of the image at the end.
