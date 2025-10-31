# Flatpak Integration Guidelines

## Overview

Flatpak provides sandboxed GUI application installation for LunarOS. Applications are defined in preinstall files and automatically installed on first boot after user setup completes.

## How Flatpak Integration Works

1. **Build Time** - Preinstall files are copied to `/etc/flatpak/preinstall.d/` in the image
2. **First Boot** - After user setup, system reads preinstall files and downloads/installs Flatpaks
3. **User Experience** - Applications appear automatically after first login

## Important: Installation Timing

**Flatpaks are NOT embedded in the image.** They are downloaded and installed after:

- User completes initial system setup
- Network connection is established
- First boot process runs `flatpak preinstall`

This means:

- ISO remains small and bootable offline
- Users need internet connection after installation
- First boot takes longer while Flatpaks download
- Applications are NOT available during offline installation

## Preinstall File Structure

### Location

All preinstall files go in `custom/flatpaks/` directory:

```
custom/flatpaks/
├── default.preinstall     # Core applications
├── development.preinstall # Development tools
├── gaming.preinstall     # Gaming applications
└── media.preinstall      # Media editing tools
```

### File Format

Preinstall files use INI format with `[Flatpak Preinstall NAME]` sections:

```ini
# Comments start with #

[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.gnome.Calculator]
Branch=stable

[Flatpak Preinstall org.gtk.Gtk3theme.adw-gtk3]
Branch=stable
IsRuntime=true
```

### Available Keys

- `Install` - (boolean) Whether to install (default: true)
- `Branch` - (string) Branch name (default: "master", commonly "stable")
- `IsRuntime` - (boolean) Whether this is a runtime (default: false for apps)
- `CollectionID` - (string) Collection ID of the remote, if any

## Creating Preinstall Files

### Core Applications (default.preinstall)

```ini
# Web browsers
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.mozilla.Thunderbird]
Branch=stable

# GNOME core apps
[Flatpak Preinstall org.gnome.Calculator]
Branch=stable

[Flatpak Preinstall org.gnome.TextEditor]
Branch=stable

[Flatpak Preinstall org.gnome.FileRoller]
Branch=stable

# System utilities
[Flatpak Preinstall com.github.tchx84.Flatseal]
Branch=stable

[Flatpak Preinstall io.missioncenter.MissionCenter]
Branch=stable
```

### Development Tools (development.preinstall)

```ini
# Code editors
[Flatpak Preinstall com.visualstudio.code]
Branch=stable

[Flatpak Preinstall org.gnome.Builder]
Branch=stable

# Development utilities
[Flatpak Preinstall com.github.Eloston.UngoogledChromium]
Branch=stable

[Flatpak Preinstall rest.insomnia.Insomnia]
Branch=stable

[Flatpak Preinstall io.dbeaver.DBeaverCommunity]
Branch=stable
```

### Gaming Applications (gaming.preinstall)

```ini
# Gaming platforms
[Flatpak Preinstall com.valvesoftware.Steam]
Branch=stable

[Flatpak Preinstall com.heroicgameslauncher.hgl]
Branch=stable

[Flatpak Preinstall org.lutris.Lutris]
Branch=stable

# Gaming utilities
[Flatpak Preinstall net.davidotek.pupgui2]
Branch=stable

[Flatpak Preinstall com.github.Matoking.protontricks]
Branch=stable
```

### Media Editing (media.preinstall)

```ini
# Image editing
[Flatpak Preinstall org.gimp.GIMP]
Branch=stable

[Flatpak Preinstall org.inkscape.Inkscape]
Branch=stable

[Flatpak Preinstall com.github.PintaProject.Pinta]
Branch=stable

# Video editing
[Flatpak Preinstall org.kde.kdenlive]
Branch=stable

[Flatpak Preinstall org.blender.Blender]
Branch=stable

# Audio editing
[Flatpak Preinstall org.audacityteam.Audacity]
Branch=stable
```

## Finding Flatpak Applications

### Search Flathub

```bash
# Search for applications
flatpak search application-name

# Get detailed info
flatpak info org.mozilla.firefox
```

### Browse Flathub Website

Visit [flathub.org](https://flathub.org/) to browse available applications and get their IDs.

### Common Application IDs

- **Browsers**: `org.mozilla.firefox`, `com.google.Chrome`, `org.chromium.Chromium`
- **Editors**: `com.visualstudio.code`, `org.gnome.TextEditor`, `org.vim.Vim`
- **Media**: `org.videolan.VLC`, `org.gimp.GIMP`, `org.audacityteam.Audacity`
- **Gaming**: `com.valvesoftware.Steam`, `org.lutris.Lutris`
- **Utilities**: `com.github.tchx84.Flatseal`, `org.gnome.Calculator`

## Best Practices

### Application Selection

- **GUI applications** - Perfect for Flatpak (browsers, editors, games)
- **Sandboxed apps** - Applications that benefit from isolation
- **User applications** - Apps users interact with directly
- **Cross-desktop apps** - Applications that work across desktop environments

### Avoid in Flatpaks

- **CLI tools** - Use Homebrew instead
- **System services** - Install at build time
- **Development runtimes** - Use Homebrew or build-time installation
- **System utilities** - Install as system packages

### Organization by Category

```ini
# Group related applications with comments

# Web browsers
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.mozilla.Thunderbird]
Branch=stable

# Development tools
[Flatpak Preinstall com.visualstudio.code]
Branch=stable

[Flatpak Preinstall org.gnome.Builder]
Branch=stable
```

### Branch Selection

```ini
# Use stable branch for production (recommended)
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

# Use beta for testing newer features
[Flatpak Preinstall org.mozilla.firefox]
Branch=beta

# Some apps only have master branch
[Flatpak Preinstall com.example.app]
Branch=master
```

## Runtime Dependencies

### GTK Themes

```ini
# Include GTK themes for consistent appearance
[Flatpak Preinstall org.gtk.Gtk3theme.adw-gtk3]
Branch=stable
IsRuntime=true

[Flatpak Preinstall org.gtk.Gtk3theme.adw-gtk3-dark]
Branch=stable
IsRuntime=true
```

### Common Runtimes

Most applications automatically install required runtimes, but you can explicitly include them:

```ini
# GNOME runtime (most GTK apps)
[Flatpak Preinstall org.gnome.Platform]
Branch=45
IsRuntime=true

# KDE runtime (Qt apps)
[Flatpak Preinstall org.kde.Platform]
Branch=5.15-21.08
IsRuntime=true

# Freedesktop runtime (basic apps)
[Flatpak Preinstall org.freedesktop.Platform]
Branch=22.08
IsRuntime=true
```

## Creating ujust Shortcuts

Create interactive Flatpak installation commands in `custom/ujust/custom-apps.just`:

```just
# Install additional Flatpaks interactively
[group('Apps')]
install-flatpaks:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    echo "Select Flatpak category to install:"
    CATEGORY=$(Choose \
        "Development - Code editors and dev tools" \
        "Gaming - Steam, Lutris, game utilities" \
        "Media - GIMP, Blender, video editors" \
        "Cancel")

    case "${CATEGORY}" in
        "Development"*)
            flatpak install -y flathub \
                com.visualstudio.code \
                org.gnome.Builder \
                rest.insomnia.Insomnia
            ;;
        "Gaming"*)
            flatpak install -y flathub \
                com.valvesoftware.Steam \
                org.lutris.Lutris \
                com.heroicgameslauncher.hgl
            ;;
        "Media"*)
            flatpak install -y flathub \
                org.gimp.GIMP \
                org.blender.Blender \
                org.kde.kdenlive
            ;;
    esac
```

## User Experience

### Automatic Installation

Applications defined in preinstall files are installed automatically:

- No user interaction required
- Happens after first boot setup
- Applications appear in application menu
- Users can uninstall if not wanted

### Manual Installation

Users can install additional Flatpaks:

```bash
# Install from Flathub
flatpak install flathub org.gimp.GIMP

# List installed applications
flatpak list --app

# Update applications
flatpak update
```

## Advanced Configuration

### Permissions and Overrides

Users can modify Flatpak permissions with Flatseal:

```ini
# Include Flatseal for permission management
[Flatpak Preinstall com.github.tchx84.Flatseal]
Branch=stable
```

### System-wide vs User Installation

Preinstall files install applications system-wide (available to all users):

- Applications appear for all users
- Requires admin privileges to uninstall
- Shared between user accounts

## Testing Preinstall Files

### Validation

```bash
# Check file syntax (basic INI validation)
# No specific flatpak validation tool, but check manually

# Verify applications exist on Flathub
flatpak search org.mozilla.firefox
```

### Local Testing

```bash
# Test installation manually
flatpak install flathub org.mozilla.firefox

# Test preinstall file (requires root)
sudo flatpak preinstall /path/to/file.preinstall
```

## Common Application Categories

### Web Browsers

```ini
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall com.google.Chrome]
Branch=stable

[Flatpak Preinstall org.chromium.Chromium]
Branch=stable
```

### Development Tools

```ini
[Flatpak Preinstall com.visualstudio.code]
Branch=stable

[Flatpak Preinstall org.gnome.Builder]
Branch=stable

[Flatpak Preinstall com.jetbrains.IntelliJ-IDEA-Community]
Branch=stable
```

### Media Applications

```ini
[Flatpak Preinstall org.videolan.VLC]
Branch=stable

[Flatpak Preinstall org.gimp.GIMP]
Branch=stable

[Flatpak Preinstall org.audacityteam.Audacity]
Branch=stable
```

### Gaming

```ini
[Flatpak Preinstall com.valvesoftware.Steam]
Branch=stable

[Flatpak Preinstall org.lutris.Lutris]
Branch=stable

[Flatpak Preinstall net.davidotek.pupgui2]
Branch=stable
```

### System Utilities

```ini
[Flatpak Preinstall com.github.tchx84.Flatseal]
Branch=stable

[Flatpak Preinstall io.missioncenter.MissionCenter]
Branch=stable

[Flatpak Preinstall org.gnome.DiskUtility]
Branch=stable
```

## Troubleshooting

### Common Issues

- **Applications not installing** - Check internet connection and Flathub availability
- **Wrong application ID** - Verify ID on Flathub website
- **Branch not found** - Check available branches with `flatpak remote-info`
- **Permission issues** - Preinstall requires system privileges

### Debugging

```bash
# Check Flatpak status
flatpak --version

# List remotes
flatpak remotes

# Check application info
flatpak remote-info flathub org.mozilla.firefox

# View installation logs
journalctl -u flatpak-system-helper
```

## Security Considerations

- **Trusted sources** - Only use applications from Flathub or trusted remotes
- **Sandboxing** - Flatpak provides application isolation by default
- **Permissions** - Review application permissions with Flatseal
- **Updates** - Keep applications updated for security patches
- **Minimal installation** - Only preinstall essential applications
