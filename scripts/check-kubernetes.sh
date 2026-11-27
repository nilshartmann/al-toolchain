#!/bin/sh
# Checks the image al-toolchain-kubernetes in addition to check.sh: kubectl and Helm start and name their
# version. Runs as a user without a home of its own, so Helm gets a writable home in /tmp.
set -eu
kubectl version --client
HOME=/tmp helm version --short
