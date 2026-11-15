#!/bin/sh
# Installs a Temurin JDK under /opt/java/<major> after checking its SHA-256.
# Usage: jdk.sh <major> <tag of the release, URL-encoded> <version in the file name> <sha256 x64> <sha256 aarch64>
set -eu
major="$1"
tag="$2"
version="$3"
case "${TARGETARCH:?}" in
  amd64) arch=x64; sha="$4" ;;
  arm64) arch=aarch64; sha="$5" ;;
  *) echo "Unsupported architecture: '$TARGETARCH'." >&2; exit 1 ;;
esac
tarball="OpenJDK${major}U-jdk_${arch}_linux_hotspot_${version}.tar.gz"
cd /tmp
curl -fsSLO "https://github.com/adoptium/temurin${major}-binaries/releases/download/${tag}/${tarball}"
echo "${sha}  ${tarball}" | sha256sum -c -
mkdir -p "/opt/java/${major}"
tar -xzf "${tarball}" -C "/opt/java/${major}" --strip-components=1
rm -f "${tarball}" "/opt/java/${major}/lib/src.zip"
"/opt/java/${major}/bin/java" -version
