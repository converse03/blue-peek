#!/usr/bin/bash
set -euo pipefail
install -Dm644 /ctx/custom/plymouth/blue-peek-boot-logo.png \
  /usr/share/plymouth/themes/bgrt/watermark.png
plymouth-set-default-theme -R bgrt