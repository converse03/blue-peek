#!/usr/bin/bash
set -euo pipefail
install -Dm644 /ctx/custom/plymouth/blue-peek-boot-logo.png \
  /usr/share/plymouth/themes/bgrt/watermark.png
plymouth-set-default-theme -R bgrt

# Without "quiet", systemd/kernel log lines print to the console instead of
# being covered by the Plymouth splash (rhgb is the traditional Fedora
# graphical-boot marker consumed by some tooling). Without this, the theme
# above is built into the initramfs but never visibly shown.
mkdir -p /usr/lib/bootc/kargs.d
tee /usr/lib/bootc/kargs.d/10-plymouth.toml <<EOF
kargs = ["rhgb", "quiet"]
EOF
