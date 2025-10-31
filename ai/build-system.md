# Build System Guidelines

## Overview

The build system uses numbered shell scripts that run during container image creation. These scripts install system packages, configure services, and make system-level modifications.

## Script Execution Order

Scripts run in numerical order based on filename:

- `10-build.sh` - Main build script (always runs first)
- `20-*.sh` - Additional software installation
- `30-*.sh` - Desktop environment changes
- `40-*.sh` - Hardware drivers
- `50-*.sh` - Final configuration and cleanup

## Required Script Structure

### Shebang and Error Handling

```bash
#!/usr/bin/bash
set -eoux pipefail
```

**Always use:**

- `#!/usr/bin/bash` - Standard bash shebang
- `set -eoux pipefail` - Strict error handling and debugging
  - `e` - Exit on any error
  - `o` - Exit on undefined variables
  - `u` - Exit on pipe failures
  - `x` - Print commands as they execute

### Script Template

```bash
#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Script Description
###############################################################################
# Brief description of what this script does
# Any important notes or warnings
###############################################################################

echo "::group:: Section Name"

# Your commands here

echo "::endgroup::"

echo "Script complete!"
```

## Package Installation

### Use dnf5 Exclusively

```bash
# ✅ Correct
dnf5 install -y package-name

# ❌ Wrong - Never use these
dnf install -y package-name
yum install -y package-name
```

### Always Use Non-Interactive Mode

```bash
# ✅ Correct - Always use -y flag
dnf5 install -y package1 package2 package3

# ❌ Wrong - Will hang waiting for input
dnf5 install package-name
```

### Multiple Packages

```bash
# Install multiple packages in one command
dnf5 install -y \
    package1 \
    package2 \
    package3
```

## Third-Party Repositories

### RPM Repositories (Temporary)

```bash
# Add repository
cat > /etc/yum.repos.d/example.repo << 'EOF'
[example]
name=Example Repository
baseurl=https://example.com/rpm/
enabled=1
gpgcheck=1
gpgkey=https://example.com/key.pub
EOF

# Install packages
dnf5 install -y package-from-repo

# REQUIRED: Clean up repo file
rm -f /etc/yum.repos.d/example.repo
```

**Important:** Always remove repository files after installation. Repositories don't work at runtime in bootc images.

### COPR Repositories (Isolated)

```bash
# Source helper functions
source /ctx/build/copr-helpers.sh

# Install from COPR using isolated pattern
copr_install_isolated "username/repository" package1 package2
```

The `copr_install_isolated` function:

1. Enables the COPR repository
2. Immediately disables it
3. Installs packages with the specific repo enabled
4. Leaves no persistent repository configuration

### GPG Key Import

```bash
# Import GPG keys before adding repositories
rpm --import https://example.com/signing-key.pub
```

## System Configuration

### Systemd Services

```bash
# Enable services
systemctl enable service-name

# Disable services
systemctl disable service-name

# Mask services (prevent activation)
systemctl mask unwanted-service
```

### File Operations

```bash
# Create directories
mkdir -p /path/to/directory

# Copy files from build context
cp /ctx/source/file /destination/path

# Create files with content
cat > /path/to/file << 'EOF'
File content here
EOF
```

## Example Scripts

### Adding Third-Party Software

Based on `build/20-onepassword.sh.example`:

```bash
#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Install Google Chrome and 1Password
###############################################################################

echo "::group:: Install Google Chrome"

# Add Google Chrome repository
cat > /etc/yum.repos.d/google-chrome.repo << 'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

# Install Chrome
dnf5 install -y google-chrome-stable

# Clean up repo file (REQUIRED)
rm -f /etc/yum.repos.d/google-chrome.repo

echo "::endgroup::"
```

### Desktop Environment Replacement

Based on `build/30-cosmic-desktop.sh.example`:

```bash
#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Replace GNOME with COSMIC Desktop
###############################################################################

source /ctx/build/copr-helpers.sh

echo "::group:: Remove GNOME Desktop"

dnf5 remove -y \
    gnome-shell \
    gnome-terminal \
    nautilus

echo "::endgroup::"

echo "::group:: Install COSMIC Desktop"

copr_install_isolated "ryanabx/cosmic-epoch" \
    cosmic-session \
    cosmic-greeter \
    cosmic-comp

echo "::endgroup::"
```

## Best Practices

### Naming Conventions

- `10-build.sh` - Main build (already exists)
- `20-drivers.sh` - Hardware drivers
- `25-nvidia.sh` - NVIDIA-specific drivers
- `30-desktop.sh` - Desktop environment changes
- `40-development.sh` - Development tools
- `50-cleanup.sh` - Final cleanup tasks

### Script Organization

- **One purpose per script** - Easier to debug and maintain
- **Descriptive names** - `20-nvidia-drivers.sh` not `20-stuff.sh`
- **Logical grouping** - Related packages in the same script
- **Clean separation** - Don't mix drivers and applications

### Error Prevention

```bash
# Check if files exist before operations
if [[ -f /path/to/file ]]; then
    rm -f /path/to/file
fi

# Verify commands succeeded
if ! command -v new-command &> /dev/null; then
    echo "ERROR: new-command not installed properly"
    exit 1
fi
```

### Cleanup Requirements

```bash
# Always clean up temporary files
rm -f /tmp/temporary-file

# Always remove repository files
rm -f /etc/yum.repos.d/temporary-repo.repo

# Clear package caches (handled automatically by build system)
```

## Testing Scripts

### Local Testing

```bash
# Build container image
just build

# Build and test VM
just build-qcow2
just run-vm-qcow2
```

### Validation

- Scripts must be executable: `chmod +x build/NN-script.sh`
- Use shellcheck for syntax validation: `just lint`
- Test incrementally - add one script at a time

## Common Patterns

### Installing from Official Repos

```bash
dnf5 install -y \
    package1 \
    package2 \
    package3
```

### Installing from Third-Party RPM Repo

```bash
# Add repo temporarily
cat > /etc/yum.repos.d/temp.repo << 'EOF'
[temp]
name=Temporary Repository
baseurl=https://example.com/rpm/
enabled=1
gpgcheck=1
gpgkey=https://example.com/key.pub
EOF

# Install packages
dnf5 install -y package-name

# Clean up (REQUIRED)
rm -f /etc/yum.repos.d/temp.repo
```

### Installing from COPR

```bash
source /ctx/build/copr-helpers.sh
copr_install_isolated "username/repo" package1 package2
```

### Replacing Desktop Environment

```bash
# Remove old desktop
dnf5 remove -y old-desktop-packages

# Install new desktop
copr_install_isolated "repo/desktop" new-desktop-packages

# Configure display manager
systemctl enable new-display-manager
```

## Security Considerations

- **Verify GPG keys** - Always import and verify repository signing keys
- **Use HTTPS** - Only download from HTTPS URLs
- **Validate sources** - Only use trusted repositories and sources
- **Clean up secrets** - Don't leave temporary keys or credentials
- **Minimal permissions** - Don't add unnecessary capabilities or permissions
