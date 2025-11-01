#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Install GNOME Shell Extensions
###############################################################################
# Installs system packages for GNOME Shell extensions at build time
###############################################################################

echo "::group:: Install GNOME Shell Extensions"

dnf5 install -y gnome-shell-extension-dash-to-panel gnome-shell-extension-arc-menu

echo "::endgroup::"
