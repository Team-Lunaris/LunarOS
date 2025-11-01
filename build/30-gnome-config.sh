#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Configure GNOME Desktop Defaults
###############################################################################
# Sets up default GNOME preferences for all users via dconf and /etc/skel
###############################################################################

echo "::group:: Configure GNOME Settings"

# Create dconf configuration directory
mkdir -p /etc/dconf/db.d/

# Create dconf keyfile for system-wide defaults
cat > /etc/dconf/db.d/00-system-defaults << 'EOF'
# GNOME Desktop Interface Settings
[org/gnome/desktop/interface]
gtk-application-prefer-dark-style=true
color-scheme='prefer-dark'
show-battery-percentage=true

# Additional GNOME appearance settings
[org/gnome/desktop/wm/preferences]
titlebar-font='Cantarell 11'

[org/gnome/settings-daemon/plugins/color]
night-light-enabled=true

# Taskbar favorite applications
[org/gnome/shell]
favorite-apps=['app.zen_browser.zen', 'org.gnome.Nautilus', 'com.visualstudio.code', 'com.github.IsmaelMartinez.teams_for_linux', 'io.github.kolunmi.Bazaar', 'io.podman_desktop.PodmanDesktop']
EOF

# Update dconf database
dconf update

echo "GNOME dark mode configured as system default"

# Create GNOME settings for /etc/skel
mkdir -p /etc/skel/.local/share/gsettings-schemas.gresource

echo "::endgroup::"
