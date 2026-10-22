#!/bin/sh
#
# Run recovery outside systemd-sleep: FastRPC needs a short time to reattach
# after s2idle, and blocking the system sleep hook delays the desktop resume.

case "$1/$2" in
post/*)
    /usr/bin/systemd-run --no-block --collect \
        /usr/libexec/nabu-sensors-recover >/dev/null 2>&1 || true
    ;;
esac
