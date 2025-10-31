# ujust Commands Guidelines

## Overview

ujust provides user-friendly command shortcuts for common system tasks. Commands are defined in `.just` files and made available to users via the `ujust` command interface.

## How ujust Works

1. **Build Time** - All `.just` files in `custom/ujust/` are consolidated into `/usr/share/ublue-os/just/60-custom.just`
2. **Runtime** - Users run `ujust` to see available commands
3. **User Experience** - Simple command interface for complex tasks

## File Structure

### Location

All ujust files go in `custom/ujust/` directory:

```
custom/ujust/
├── README.md           # Documentation
├── custom-apps.just    # Application installation commands
├── custom-system.just  # System configuration commands
├── custom-gaming.just  # Gaming-related commands (example)
└── custom-dev.just     # Development commands (example)
```

### File Naming Convention

- Use `custom-` prefix: `custom-apps.just`, `custom-system.just`
- Use descriptive names: `custom-gaming.just`, `custom-media.just`
- Use `.just` extension (required)

## Command Structure

### Basic Command

```just
# Brief description of what the command does
command-name:
    echo "Running command..."
    # Your commands here
```

### Command with Group

```just
# Groups organize commands in ujust help output
[group('Apps')]
install-something:
    echo "Installing something..."
```

### Multi-line Script Command

```just
# Use bash shebang for complex scripts
[group('System')]
configure-firewall:
    #!/usr/bin/bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures

    echo "Configuring firewall..."
    sudo firewall-cmd --permanent --add-service=ssh
    sudo firewall-cmd --reload
    echo "Firewall configured successfully"
```

### Interactive Command

```just
# Use gum for user interaction
[group('Apps')]
install-brewfile:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh  # Provides Choose() and other helpers

    echo "Select Brewfile to install:"
    BREWFILE=$(Choose \
        "default.Brewfile - Essential CLI tools" \
        "development.Brewfile - Development tools" \
        "fonts.Brewfile - Programming fonts" \
        "Cancel")

    if [[ "${BREWFILE}" == "Cancel" ]]; then
        echo "Installation cancelled"
        exit 0
    fi

    BREWFILE_NAME=$(echo "${BREWFILE}" | cut -d' ' -f1)
    brew bundle --file "/usr/share/ublue-os/homebrew/${BREWFILE_NAME}"
```

## Command Categories and Groups

### Recommended Groups

- `Apps` - Application installation and management
- `System` - System configuration and maintenance
- `Development` - Development environment setup
- `Gaming` - Gaming-related tasks
- `Media` - Media editing and creation tools
- `Maintenance` - System cleanup and optimization

### Example Commands by Category

#### Apps Group

```just
[group('Apps')]
install-default-apps:
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

[group('Apps')]
install-dev-tools:
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile

[group('Apps')]
install-flatpaks:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    CATEGORY=$(Choose \
        "Development - Code editors and dev tools" \
        "Gaming - Steam, Lutris, game utilities" \
        "Media - GIMP, Blender, video editors" \
        "Cancel")

    case "${CATEGORY}" in
        "Development"*)
            flatpak install -y flathub com.visualstudio.code org.gnome.Builder
            ;;
        "Gaming"*)
            flatpak install -y flathub com.valvesoftware.Steam org.lutris.Lutris
            ;;
        "Media"*)
            flatpak install -y flathub org.gimp.GIMP org.blender.Blender
            ;;
    esac
```

#### System Group

```just
[group('System')]
configure-gaming:
    #!/usr/bin/bash
    echo "Configuring system for gaming..."

    # Enable GameMode
    sudo systemctl enable --now gamemode

    # Configure kernel parameters for gaming
    echo 'vm.max_map_count=2147483642' | sudo tee /etc/sysctl.d/99-gaming.conf
    sudo sysctl -p /etc/sysctl.d/99-gaming.conf

    echo "Gaming configuration complete!"

[group('System')]
setup-development:
    #!/usr/bin/bash
    echo "Setting up development environment..."

    # Add user to docker group
    sudo usermod -aG docker $USER

    # Enable podman socket
    systemctl --user enable --now podman.socket

    echo "Development setup complete! Please log out and back in."
```

#### Maintenance Group

```just
[group('Maintenance')]
clean-system:
    #!/usr/bin/bash
    echo "Cleaning system..."

    # Clean package caches
    brew cleanup
    flatpak uninstall --unused -y

    # Clean containers
    podman system prune -af

    # Clean logs
    sudo journalctl --vacuum-time=7d

    echo "System cleanup complete!"

[group('Maintenance')]
update-system:
    #!/usr/bin/bash
    echo "Updating system..."

    # Update bootc image
    sudo bootc upgrade

    # Update Homebrew packages
    brew update && brew upgrade

    # Update Flatpaks
    flatpak update -y

    echo "System update complete! Reboot to apply bootc changes."
```

## Best Practices

### Naming Conventions

Use verb prefixes for clarity:

- `install-` - Install something new
- `configure-` - Configure something already installed
- `setup-` - Install and configure together
- `toggle-` - Enable/disable a feature
- `fix-` - Apply a fix or workaround
- `clean-` - Clean up or remove things
- `update-` - Update existing software

Examples:

- `install-dev-tools` ✅
- `configure-firewall` ✅
- `setup-gaming` ✅
- `toggle-dark-mode` ✅
- `fix-audio-issues` ✅

### Error Handling

```just
command-with-error-handling:
    #!/usr/bin/bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures

    # Check prerequisites
    if ! command -v brew &> /dev/null; then
        echo "ERROR: Homebrew not installed"
        exit 1
    fi

    # Your commands here
    echo "Command completed successfully"
```

### User Feedback

```just
verbose-command:
    #!/usr/bin/bash
    echo "Starting configuration..."

    echo "Step 1: Configuring service..."
    sudo systemctl enable service-name

    echo "Step 2: Setting permissions..."
    sudo usermod -aG group-name $USER

    echo "Configuration complete!"
    echo "Please log out and back in for changes to take effect."
```

### Confirmation Prompts

```just
destructive-command:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    echo "This will remove all Docker containers and images."
    if Confirm "Are you sure you want to continue?"; then
        docker system prune -af --volumes
        echo "Docker cleanup complete"
    else
        echo "Operation cancelled"
    fi
```

## Available Helper Functions

Universal Blue images include helpers in `/usr/lib/ujust/ujust.sh`:

### Choose Function

```just
interactive-choice:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    OPTION=$(Choose "Option 1" "Option 2" "Option 3" "Cancel")
    echo "You selected: $OPTION"
```

### Confirm Function

```just
confirmation-example:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    if Confirm "Do you want to proceed?"; then
        echo "Proceeding..."
    else
        echo "Cancelled"
    fi
```

### Color Variables

```just
colorful-output:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    echo "${bold}Bold text${normal}"
    echo "${red}Red text${normal}"
    echo "${green}Green text${normal}"
```

## Common Use Cases

### Brewfile Shortcuts

```just
[group('Apps')]
install-fonts:
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile

[group('Apps')]
install-cli-tools:
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile
```

### System Configuration

```just
[group('System')]
enable-flathub:
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

[group('System')]
configure-git:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    echo "Configure Git settings:"
    read -p "Enter your name: " GIT_NAME
    read -p "Enter your email: " GIT_EMAIL

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

    echo "Git configured successfully!"
```

### Development Environment

```just
[group('Development')]
setup-nodejs:
    #!/usr/bin/bash
    # Install Node Version Manager
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts

    echo "Node.js setup complete!"

[group('Development')]
setup-python:
    #!/usr/bin/bash
    # Install pyenv
    curl https://pyenv.run | bash

    echo "Python environment manager installed!"
    echo "Add pyenv to your shell profile and restart your terminal."
```

## Important Constraints

### No Package Installation via dnf/rpm

```just
# ❌ Wrong - Don't install system packages
bad-command:
    sudo dnf install package-name

# ✅ Correct - Use Homebrew or Flatpak
good-command:
    brew install package-name
    # or
    flatpak install flathub org.example.App
```

### Use Appropriate Package Managers

- **CLI tools** - Use Homebrew
- **GUI applications** - Use Flatpak
- **Development environments** - Use language-specific managers (nvm, pyenv, etc.)
- **Containers** - Use Podman/Docker

### Privilege Escalation

```just
# Use sudo only when necessary
system-config:
    #!/usr/bin/bash
    # User operations (no sudo needed)
    brew install package-name

    # System operations (sudo required)
    sudo systemctl enable service-name
```

## Testing Commands

### Local Testing

```bash
# Test just files directly
just --justfile custom/ujust/custom-apps.just --list
just --justfile custom/ujust/custom-apps.just install-something

# Test after building image
just build
# Deploy and test: ujust your-command
```

### Validation

- Commands must be executable and error-free
- Use shellcheck for bash script validation: `just lint`
- Test with different user permissions
- Verify all dependencies are available

## Advanced Patterns

### Conditional Execution

```just
conditional-command:
    #!/usr/bin/bash
    if command -v docker &> /dev/null; then
        echo "Docker is installed"
        docker --version
    else
        echo "Docker not found, installing via Homebrew..."
        brew install docker
    fi
```

### Loop Operations

```just
batch-install:
    #!/usr/bin/bash
    PACKAGES=("bat" "eza" "ripgrep" "fd")

    for package in "${PACKAGES[@]}"; do
        echo "Installing $package..."
        brew install "$package"
    done
```

### File Operations

```just
backup-configs:
    #!/usr/bin/bash
    BACKUP_DIR="$HOME/config-backup-$(date +%Y%m%d)"
    mkdir -p "$BACKUP_DIR"

    # Backup configuration files
    cp -r ~/.config/git "$BACKUP_DIR/"
    cp ~/.bashrc "$BACKUP_DIR/"

    echo "Configurations backed up to $BACKUP_DIR"
```

## Documentation

### Command Documentation

```just
# Always include brief description
# Longer description can go in comments above the command
#
# This command sets up a complete development environment
# including Git configuration, SSH keys, and development tools
[group('Development')]
setup-dev-environment:
    #!/usr/bin/bash
    echo "Setting up development environment..."
    # Implementation here
```

### Help Commands

```just
# Create help commands for complex workflows
[group('Help')]
help-development:
    #!/usr/bin/bash
    cat << 'EOF'
Development Environment Setup:

1. ujust setup-dev-environment  - Complete dev setup
2. ujust install-dev-tools      - Install development Brewfile
3. ujust configure-git          - Configure Git settings
4. ujust setup-nodejs           - Install Node.js via nvm
5. ujust setup-python           - Install Python via pyenv

For more information, see: https://github.com/your-repo/wiki
EOF
```
