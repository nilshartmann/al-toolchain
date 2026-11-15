#!/bin/sh
# Checks the built image: every JDK, Maven, Node, npm and corepack start and name their version, the
# shims of corepack are there, and the German locale and the time zone data exist. pnpm itself is not
# started, because corepack would download it. Runs as a user without a home of its own.
set -eu
for major in 17 21 25 26; do
  "/opt/java/${major}/bin/java" -version 2>&1 | head -1
done
echo "JAVA_HOME=${JAVA_HOME}"
java -version 2>&1 | head -1
mvn -v | head -1
node --version
npm --version
echo "corepack $(corepack --version)"
test -x "$(command -v pnpm)"
locale -a | grep -qi '^de_DE\.utf8$'
TZ=Europe/Berlin date +%Z | grep -Eq '^CES?T$'
echo "pnpm through corepack, de_DE.UTF-8 and Europe/Berlin present"
