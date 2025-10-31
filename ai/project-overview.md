# LunarOS Project Overview

## What is LunarOS?

LunarOS is a custom bootc operating system image based on Universal Blue and Bluefin conventions. It provides a template for building immutable Linux distributions with modern tooling and declarative configuration.

## Project Structure

```
├── ai/                          # AI agent steering documentation
├── build/                       # Build-time scripts (run during image creation)
│   ├── 10-build.sh             # Main build script
│   ├── 20-*.sh.example         # Example scripts for adding software
│   └── copr-helpers.sh         # Helper functions for COPR repositories
├── custom/                      # Runtime customization files
│   ├── brew/                   # Homebrew Brewfiles for runtime packages
│   ├── flatpaks/              # Flatpak preinstall configurations
│   └── ujust/                 # User-facing just commands
├── iso/                        # ISO/VM build configurations
├── Containerfile              # Main container build definition
├── Justfile                   # Development and build commands
└── README.md                  # User documentation
```

## Key Concepts

### Immutable Base System

- The base system is read-only and cannot be modified at runtime
- All system packages must be installed during the build process
- Users cannot use `dnf`/`rpm` to install packages after deployment

### Layered Customization

1. **Build-time (build/)** - System packages, drivers, core modifications
2. **Runtime (custom/)** - User applications, configurations, convenience commands

### Universal Blue Conventions

- Uses `dnf5` exclusively (never `dnf` or `yum`)
- Follows numbered script execution (10-, 20-, 30-)
- Cleans up temporary repositories after installation
- Uses `set -eoux pipefail` for strict error handling

## Base Images

LunarOS can be built on various base images:

- `ghcr.io/ublue-os/bluefin:stable` (default) - GNOME desktop with developer tools
- `ghcr.io/ublue-os/bazzite:latest` - Gaming-focused distribution
- `ghcr.io/ublue-os/bluefin-nvidia:stable` - NVIDIA driver support
- `quay.io/fedora/fedora-bootc:41` - Minimal Fedora base

## Build Process

1. **Container Build** - Containerfile defines the image build process
2. **Script Execution** - Build scripts run in numerical order
3. **File Copying** - Custom files are copied to system locations
4. **Image Creation** - Bootable images (ISO, QCOW2, RAW) can be generated

## Runtime Package Management

### Homebrew (Recommended)

- Cross-platform package manager
- Installs to user space (`~/.linuxbrew`)
- Declarative via Brewfiles
- Supports CLI tools, development environments

### Flatpak

- Sandboxed GUI applications
- Installed system-wide but isolated
- Automatic installation via preinstall files
- Source: Flathub repository

### Containers (Advanced)

- Toolbox/Distrobox for development environments
- Podman for containerized applications
- Full isolation from host system

## User Experience

### ujust Commands

- Simplified interface for common tasks
- `ujust install-dev-tools` - Install development Brewfile
- `ujust configure-system` - System configuration tasks
- `ujust maintenance` - System maintenance operations

### Bootc Management

- `bootc switch` - Change to different image
- `bootc upgrade` - Update to newer version
- `bootc rollback` - Revert to previous version

## Development Workflow

1. **Local Development** - Use `just build` to test changes
2. **Pull Requests** - All changes go through PR validation
3. **Automated Testing** - GitHub Actions validate builds and syntax
4. **Deployment** - Merge to main triggers stable image build

## Security Features

- Optional image signing with cosign
- SBOM (Software Bill of Materials) generation
- Automated security updates via Renovate
- Build provenance tracking

## Customization Points

### Adding Software

- **System packages** - Add to `build/10-build.sh` or create new build scripts
- **User applications** - Add to Brewfiles or Flatpak preinstall files
- **Third-party repos** - Use example scripts in `build/` directory

### Configuration

- **System services** - Enable/disable in build scripts
- **User commands** - Add ujust commands for common tasks
- **Desktop environment** - Replace GNOME with alternatives (see examples)

## File Naming Conventions

- **Build scripts** - `NN-description.sh` (e.g., `20-nvidia-drivers.sh`)
- **Brewfiles** - `category.Brewfile` (e.g., `development.Brewfile`)
- **Flatpak files** - `category.preinstall` (e.g., `gaming.preinstall`)
- **ujust files** - `custom-category.just` (e.g., `custom-gaming.just`)

## Important Constraints

- **No runtime package installation** - Use Homebrew or Flatpak instead
- **Clean up build artifacts** - Remove temporary repos and files
- **Test before committing** - Use local build and VM testing
- **Follow security guidelines** - Validate all inputs and sources
