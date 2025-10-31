# Homebrew Integration Guidelines

## Overview

Homebrew provides runtime package management for LunarOS users. Unlike system packages that are installed at build time, Homebrew packages are installed by users after deployment to their home directory (`~/.linuxbrew`).

## How Homebrew Integration Works

1. **Build Time** - Brewfiles are copied to `/usr/share/ublue-os/homebrew/` in the image
2. **Runtime** - Users run `brew bundle` commands to install packages
3. **User Experience** - Declarative package management with ujust shortcuts

## Brewfile Structure

### Location

All Brewfiles go in `custom/brew/` directory:

```
custom/brew/
├── default.Brewfile      # Essential CLI tools
├── development.Brewfile  # Development tools and languages
├── fonts.Brewfile       # Programming fonts
└── gaming.Brewfile      # Gaming-related tools (example)
```

### File Format

Brewfiles use Ruby syntax:

```ruby
# Comments start with #

# Add a tap (third-party repository)
tap "homebrew/cask"
tap "homebrew/cask-fonts"

# Install a formula (CLI tool)
brew "bat"              # cat with syntax highlighting
brew "eza"              # Modern replacement for ls
brew "ripgrep"          # Fast text search
brew "fd"               # Simple, fast alternative to find

# Install a cask (GUI application - macOS only, ignore on Linux)
cask "visual-studio-code"

# Install from specific tap
brew "username/tap/package"
```

## Creating Brewfiles

### Essential Tools (default.Brewfile)

```ruby
# Modern CLI replacements
brew "bat"        # Better cat
brew "eza"        # Better ls
brew "fd"         # Better find
brew "ripgrep"    # Better grep
brew "zoxide"     # Better cd

# Development essentials
brew "git"        # Version control
brew "gh"         # GitHub CLI

# Shell enhancements
brew "starship"   # Cross-shell prompt
brew "tmux"       # Terminal multiplexer

# System utilities
brew "htop"       # Process viewer
brew "tree"       # Directory tree viewer
```

### Development Tools (development.Brewfile)

```ruby
# Programming languages
brew "node"       # Node.js
brew "python@3.11" # Python
brew "go"         # Go language
brew "rust"       # Rust language

# Development tools
brew "docker"     # Container runtime
brew "kubectl"    # Kubernetes CLI
brew "terraform"  # Infrastructure as code
brew "ansible"    # Configuration management

# Editors and IDEs (CLI)
brew "neovim"     # Modern vim
brew "emacs"      # Emacs editor

# Build tools
brew "cmake"      # Build system
brew "make"       # GNU Make
brew "ninja"      # Fast build system
```

### Fonts (fonts.Brewfile)

```ruby
# Add fonts tap
tap "homebrew/cask-fonts"

# Programming fonts
brew "font-fira-code"
brew "font-jetbrains-mono"
brew "font-source-code-pro"
brew "font-cascadia-code"
brew "font-hack"

# Nerd Fonts (with icons)
brew "font-fira-code-nerd-font"
brew "font-jetbrains-mono-nerd-font"
```

## Best Practices

### Package Selection

- **CLI tools** - Perfect for Homebrew (bat, eza, ripgrep, etc.)
- **Development tools** - Languages, build tools, utilities
- **Cross-platform tools** - Tools that work on Linux and macOS
- **User-space applications** - Tools that don't require system integration

### Avoid in Brewfiles

- **System packages** - Use build scripts instead
- **GUI applications** - Use Flatpak preinstall instead
- **System services** - Install at build time
- **Drivers** - Must be installed at build time

### Organization

```ruby
# Group related packages with comments
# Text processing tools
brew "bat"
brew "ripgrep"
brew "fd"

# Development languages
brew "node"
brew "python@3.11"
brew "go"

# Container tools
brew "docker"
brew "podman"
brew "kubectl"
```

### Version Pinning

```ruby
# Pin specific versions when needed
brew "python@3.11"    # Specific Python version
brew "node@18"        # Specific Node.js version

# Use latest version (default)
brew "git"            # Latest stable version
```

## Creating ujust Shortcuts

For each Brewfile, create corresponding ujust commands in `custom/ujust/custom-apps.just`:

```just
# Install default CLI tools
[group('Apps')]
install-default-apps:
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

# Install development tools
[group('Apps')]
install-dev-tools:
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile

# Install programming fonts
[group('Apps')]
install-fonts:
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile
```

## User Experience

### Installation Commands

Users can install packages using:

```bash
# Direct brew bundle command
brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

# Convenient ujust shortcuts
ujust install-default-apps
ujust install-dev-tools
ujust install-fonts
```

### Interactive Installation

Create interactive ujust commands:

```just
[group('Apps')]
install-brewfile:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    echo "Available Brewfiles:"
    BREWFILE=$(Choose \
        "default.Brewfile - Essential CLI tools" \
        "development.Brewfile - Development tools" \
        "fonts.Brewfile - Programming fonts" \
        "Cancel")

    if [[ "${BREWFILE}" == "Cancel" ]]; then
        exit 0
    fi

    BREWFILE_NAME=$(echo "${BREWFILE}" | cut -d' ' -f1)
    brew bundle --file "/usr/share/ublue-os/homebrew/${BREWFILE_NAME}"
```

## Advanced Patterns

### Conditional Installation

```ruby
# Install different packages based on architecture
if Hardware::CPU.arm?
  brew "package-arm"
else
  brew "package-x86"
end

# Install based on OS (though this is Linux-focused)
if OS.linux?
  brew "linux-specific-tool"
end
```

### Custom Taps

```ruby
# Add custom tap for specialized tools
tap "username/custom-tools"
brew "username/custom-tools/special-package"
```

### Bundle Configuration

```ruby
# Brewfile can include bundle configuration
# This goes at the top of the file

# Require specific Homebrew version
# homebrew ">=3.0.0"

# Set bundle options
# cask_args appdir: "/Applications"
```

## Testing Brewfiles

### Validation

```bash
# Check Brewfile syntax
brew bundle check --file custom/brew/default.Brewfile

# Dry run installation
brew bundle --file custom/brew/default.Brewfile --dry-run
```

### Local Testing

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Test Brewfile installation
brew bundle --file custom/brew/default.Brewfile
```

## Common Packages by Category

### Essential CLI Tools

```ruby
brew "bat"        # Better cat
brew "eza"        # Better ls
brew "fd"         # Better find
brew "ripgrep"    # Better grep
brew "zoxide"     # Better cd
brew "fzf"        # Fuzzy finder
brew "tree"       # Directory tree
brew "htop"       # Process viewer
```

### Development Languages

```ruby
brew "node"       # Node.js
brew "python@3.11" # Python
brew "go"         # Go
brew "rust"       # Rust
brew "ruby"       # Ruby
brew "java"       # Java (OpenJDK)
```

### Development Tools

```ruby
brew "git"        # Version control
brew "gh"         # GitHub CLI
brew "docker"     # Containers
brew "kubectl"    # Kubernetes
brew "terraform"  # Infrastructure
brew "ansible"    # Configuration
```

### Shell Enhancement

```ruby
brew "starship"   # Cross-shell prompt
brew "tmux"       # Terminal multiplexer
brew "zsh"        # Z shell
brew "fish"       # Fish shell
```

### Text Editors

```ruby
brew "neovim"     # Modern vim
brew "emacs"      # Emacs
brew "micro"      # Simple terminal editor
```

## Troubleshooting

### Common Issues

- **Permission errors** - Homebrew installs to user directory, no sudo needed
- **Missing dependencies** - Homebrew handles dependencies automatically
- **Tap not found** - Verify tap name and availability
- **Package conflicts** - Use `brew doctor` to diagnose

### Debugging

```bash
# Check Homebrew installation
brew doctor

# List installed packages
brew list

# Check package info
brew info package-name

# Update Homebrew
brew update
```

## Security Considerations

- **Trusted sources** - Only use official Homebrew taps and well-known third-party taps
- **Verify packages** - Check package descriptions and maintainers
- **Regular updates** - Keep Homebrew and packages updated
- **Minimal installation** - Only install packages that are actually needed
