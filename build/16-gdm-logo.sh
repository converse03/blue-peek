#!/usr/bin/bash
set -euo pipefail

###############################################################################
# GDM Login Screen Logo
###############################################################################
# Sets the greeter logo (org.gnome.login-screen logo key) shown on the GNOME
# login screen. GDM scales it automatically to a 48px-tall thumbnail, so the
# same wide brand asset used for the Plymouth boot splash works fine here too.
# See: https://help.gnome.org/admin/system-admin-guide/stable/login-logo.html.en
###############################################################################

install -Dm644 /ctx/custom/plymouth/blue-peek-boot-logo.png \
	/usr/share/pixmaps/blue-peek-logo.png

# The gdm package already ships this profile on Fedora; only create it if
# it's somehow missing, so we don't clobber anything else it might define.
if [[ ! -f /etc/dconf/profile/gdm ]]; then
	mkdir -p /etc/dconf/profile
	tee /etc/dconf/profile/gdm <<EOF
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
fi

mkdir -p /etc/dconf/db/gdm.d
tee /etc/dconf/db/gdm.d/01-logo <<EOF
[org/gnome/login-screen]
logo='/usr/share/pixmaps/blue-peek-logo.png'
EOF

# Compile the text keyfiles above into the binary db GDM actually reads.
dconf update
