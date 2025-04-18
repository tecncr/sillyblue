#!/bin/bash

set -eoux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

curl -o /etc/yum.repos.d/negativo17-fedora-multimedia.repo https://negativo17.org/repos/fedora-multimedia.repo

### BUILD evdi (succeed or fail-fast with debug output)
export CFLAGS="-fno-pie -no-pie"
dnf install -y \
  kmod-evdi*.fc"${RELEASE}.${ARCH}" akmod-evdi-*.fc"${RELEASE}.${ARCH}"
akmods --force --kernels "${KERNEL}" --kmod evdi
modinfo /usr/lib/modules/"${KERNEL}"/extra/evdi/evdi.ko.xz >/dev/null ||
  (find /var/cache/akmods/evdi/ -name \*.log -print -exec cat {} \; && exit 1)

rm -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo
unset CFLAGS
