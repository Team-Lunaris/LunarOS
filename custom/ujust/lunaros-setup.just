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
    dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-style true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/desktop/interface/show-battery-percentage true
    dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true
    dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Cantarell 11'"

    # Set taskbar favorite applications
    echo "Configuring taskbar favorites..."
    dconf write /org/gnome/shell/favorite-apps "['app.zen_browser.zen', 'org.gnome.Nautilus', 'com.visualstudio.code', 'com.github.IsmaelMartinez.teams_for_linux', 'io.github.kolunmi.Bazaar', 'io.podman_desktop.PodmanDesktop']"

    # Configure extensions
    echo "Configuring GNOME extensions..."
    dconf write /org/gnome/shell/enabled-extensions "['dash-to-panel@jderose9.github.com', 'arcmenu@arcmenu.com']"
    dconf write /org/gnome/shell/disabled-extensions "['dash-to-dock@micxgo.github.com', 'gsconnect@andyholmes.github.io', 'logomenu@aryan20.com']"

    echo "LunarOS GNOME setup complete!"
