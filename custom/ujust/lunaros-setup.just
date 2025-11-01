# LunarOS Setup
# Configure GNOME desktop environment with LunarOS defaults

# Configure LunarOS GNOME Defaults
[group('LunarOS')]
setup-lunaros:
    #!/usr/bin/bash
    set -eoux pipefail

    echo "Setting up LunarOS GNOME defaults..."

    # Apply GNOME dconf settings
    echo "Applying GNOME settings..."
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Cantarell 11"

    # Configure extensions
    echo "Configuring GNOME extensions..."
    gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com', 'arcmenu@arcmenu.com']"
    gsettings set org.gnome.shell disabled-extensions "['dash-to-dock@micxgo.github.com', 'gsconnect@andyholmes.github.io', 'logomenu@aryan20.com']"

    echo "LunarOS GNOME setup complete!"
    echo "Note: Log out and back in for all changes to take full effect."
