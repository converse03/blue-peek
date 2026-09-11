#!/usr/bin/bash
set -euo pipefail

###############################################################################
# Default dconf Settings
###############################################################################
# System-wide default GSettings values. These are defaults only — users can
# still change them in Settings; nothing here is locked/mandatory.
# See: https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en
###############################################################################

# Fedora Workstation already ships this profile; only create it if it's
# somehow missing, so we don't clobber anything else it might define.
if [[ ! -f /etc/dconf/profile/user ]]; then
	mkdir -p /etc/dconf/profile
	tee /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF
fi

mkdir -p /etc/dconf/db/local.d
tee /etc/dconf/db/local.d/00-interface <<EOF
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
EOF

# Default desktop/lock-screen background.
install -Dm644 /ctx/custom/branding/background.png \
	/usr/share/backgrounds/blue-peek/background.png
tee /etc/dconf/db/local.d/01-background <<EOF
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/blue-peek/background.png'
picture-uri-dark='file:///usr/share/backgrounds/blue-peek/background.png'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/blue-peek/background.png'
EOF

# Compile the text keyfiles above into the binary db GNOME actually reads.
dconf update
