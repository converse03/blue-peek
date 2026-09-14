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

tee /etc/dconf/db/local.d/01-background <<EOF
[org/gnome/desktop/background]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/gnome/curvy-l.jxl'
picture-uri-dark='file:///usr/share/backgrounds/gnome/curvy-d.jxl'
primary-color='#86b6ef'
secondary-color='#000000'
EOF

tee /etc/dconf/db/local.d/02-background-logo <<EOF
[org/fedorahosted/background-logo-extension]
logo-file-dark='/usr/share/pixmaps/inpeek-logo-lightblue.svg'
logo-position='bottom-right'
logo-size=11.45021645021645
EOF

# Compile the text keyfiles above into the binary db GNOME actually reads.
dconf update
