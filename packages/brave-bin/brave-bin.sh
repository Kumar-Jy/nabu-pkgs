#!/usr/bin/env bash

# Launcher for the prebuilt Brave release installed under /opt/brave-bin.
# Users can override the flags in ~/.config/brave-flags.conf (one flag per
# line); otherwise Wayland and VA-API hardware video decode are enabled.

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
CONF_FILE="${XDG_CONFIG_HOME}/brave-flags.conf"

if [ -f "${CONF_FILE}" ]; then
    mapfile -t FLAG_LIST < "${CONF_FILE}"
else
    FLAG_LIST=(
        "--ozone-platform-hint=auto"
        "--ignore-gpu-blocklist"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,PlatformHEVCDecoderSupport"
    )
fi

export CHROME_VERSION_EXTRA='stable'

exec /opt/brave-bin/brave "${FLAG_LIST[@]}" "$@"
