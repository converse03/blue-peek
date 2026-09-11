#!/usr/bin/bash

set -euo pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -euo pipefail for strict error handling.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Overlay Brew Integration Files"

# Brew integration files from @ublue-os/brew OCI (tarball, systemd services, shell integration)
rsync -rvK /ctx/oci/brew/ /

echo "::endgroup::"

echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
mkdir -p /usr/share/ublue-os/just/
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >>/usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /usr/share/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /usr/share/flatpak/preinstall.d/

echo "::endgroup::"

echo "::group:: Configure Flatpak Remotes"

# `flatpak remote-add` writes into /var/lib/flatpak, but /var is not part of
# the committed image (clean-stage.sh wipes it, and ostree/bootc don't carry
# build-time /var content into the deployment anyway) — that state would
# never reach first boot. Flatpak also supports statically preconfigured
# remotes: a .flatpakrepo file dropped into /usr/share/flatpak/remotes.d/
# is picked up automatically, and /usr *is* part of the image. Fetch the
# real file (with its current signing key) instead of hand-authoring one.
mkdir -p /usr/share/flatpak/remotes.d/
curl -fsSL --retry 3 https://dl.flathub.org/repo/flathub.flatpakrepo \
	-o /usr/share/flatpak/remotes.d/flathub.flatpakrepo

# Install the oneshot service that actually processes
# /usr/share/flatpak/preinstall.d/ on first boot (enabled below). Just
# shipping the preinstall files does nothing without a trigger to run
# `flatpak preinstall`.
install -Dm644 /ctx/custom/systemd/flatpak-preinstall.service \
	/usr/lib/systemd/system/flatpak-preinstall.service

echo "::endgroup::"

echo "::group:: Install Packages"

# Install the default packages and verify the DNF cache is working.
# gum is required by the default ujust recipes for interactive prompts.
dnf5 install -y tmux gum

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket
systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer
systemctl enable flatpak-preinstall.service
# Example: systemctl mask unwanted-service

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
