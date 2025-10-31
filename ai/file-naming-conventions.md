# File Naming Conventions

## Overview

Consistent file naming is crucial for maintainability, automation, and team collaboration. This document defines the naming conventions used throughout the LunarOS project.

## Build Scripts

### Pattern: `NN-description.sh`

Build scripts use numerical prefixes to control execution order:

```
build/
├── 10-build.sh              # Main build script (always first)
├── 20-nvidia-drivers.sh     # Hardware drivers
├── 25-amd-drivers.sh        # Alternative hardware drivers
├── 30-cosmic-desktop.sh     # Desktop environment replacement
├── 40-development-tools.sh  # Development packages
├── 50-gaming-setup.sh       # Gaming-specific configuration
└── 90-cleanup.sh            # Final cleanup tasks
```

### Numbering Guidelines

- **10-19**: Core system modifications, main build script
- **20-29**: Hardware drivers and firmware
- **30-39**: Desktop environment changes
- **40-49**: Application categories (development, gaming, media)
- **50-59**: User experience enhancements
- **60-69**: Security and compliance
- **70-79**: Performance optimizations
- **80-89**: Integration and compatibility
- **90-99**: Cleanup and finalization

### Naming Rules

- Use lowercase with hyphens: `nvidia-drivers.sh` ✅
- Be descriptive: `development-tools.sh` ✅ not `dev.sh` ❌
- Use singular form: `nvidia-driver.sh` ✅ not `nvidia-drivers.sh` ❌
- Avoid abbreviations: `development.sh` ✅ not `dev.sh` ❌

### Examples

```bash
# ✅ Good names
20-nvidia-driver.sh
25-amd-driver.sh
30-cosmic-desktop.sh
40-development-tools.sh
50-gaming-setup.sh

# ❌ Bad names
drivers.sh              # No number, not specific
20-stuff.sh            # Not descriptive
30-DE.sh               # Abbreviation
40-dev_tools.sh        # Underscore instead of hyphen
```

## Homebrew Brewfiles

### Pattern: `category.Brewfile`

Brewfiles are named by their purpose or category:

```
custom/brew/
├── default.Brewfile        # Essential CLI tools
├── development.Brewfile    # Development tools and languages
├── fonts.Brewfile         # Programming and system fonts
├── gaming.Brewfile        # Gaming-related CLI tools
├── media.Brewfile         # Media editing CLI tools
└── security.Brewfile      # Security and privacy tools
```

### Naming Rules

- Use lowercase: `development.Brewfile` ✅
- Use descriptive categories: `development.Brewfile` ✅ not `dev.Brewfile` ❌
- Use `.Brewfile` extension (capital B)
- Avoid spaces or special characters

### Examples

```bash
# ✅ Good names
default.Brewfile
development.Brewfile
fonts.Brewfile
gaming.Brewfile
media-editing.Brewfile
security-tools.Brewfile

# ❌ Bad names
dev.Brewfile           # Abbreviation
Development.brewfile   # Wrong case
gaming_tools.Brewfile  # Underscore
media editing.Brewfile # Space
```

## Flatpak Preinstall Files

### Pattern: `category.preinstall`

Preinstall files are named by application category:

```
custom/flatpaks/
├── default.preinstall        # Core applications
├── development.preinstall    # Development tools and IDEs
├── gaming.preinstall        # Gaming platforms and utilities
├── media.preinstall         # Media editing applications
├── office.preinstall        # Office and productivity apps
└── graphics.preinstall      # Graphics and design tools
```

### Naming Rules

- Use lowercase: `development.preinstall` ✅
- Use descriptive categories: `development.preinstall` ✅ not `dev.preinstall` ❌
- Use `.preinstall` extension (lowercase)
- Match Brewfile categories when possible

### Examples

```bash
# ✅ Good names
default.preinstall
development.preinstall
gaming.preinstall
media-editing.preinstall
office-suite.preinstall

# ❌ Bad names
dev.preinstall         # Abbreviation
Development.preinstall # Wrong case
gaming_apps.preinstall # Underscore
media editing.preinstall # Space
```

## ujust Command Files

### Pattern: `custom-category.just`

ujust files use the `custom-` prefix to distinguish from system files:

```
custom/ujust/
├── custom-apps.just      # Application installation commands
├── custom-system.just    # System configuration commands
├── custom-gaming.just    # Gaming-related commands
├── custom-dev.just       # Development environment setup
└── custom-media.just     # Media editing workflows
```

### Naming Rules

- Use `custom-` prefix: `custom-apps.just` ✅
- Use lowercase with hyphens: `custom-gaming.just` ✅
- Use `.just` extension (lowercase)
- Be descriptive: `custom-development.just` ✅ not `custom-dev.just` ❌

### Examples

```bash
# ✅ Good names
custom-apps.just
custom-system.just
custom-gaming.just
custom-development.just
custom-media-editing.just

# ❌ Bad names
apps.just              # Missing custom- prefix
custom_gaming.just     # Underscore
custom-dev.just        # Abbreviation
Custom-Apps.just       # Wrong case
```

## ujust Command Names

### Pattern: `verb-object` or `verb-adjective-object`

Individual ujust commands use verb-object naming:

```just
# ✅ Good command names
install-dev-tools
configure-firewall
setup-gaming
toggle-dark-mode
fix-audio-issues
clean-containers
update-system

# ❌ Bad command names
devtools              # No verb, abbreviation
install_dev_tools     # Underscore
installDevTools       # CamelCase
dev-setup            # Abbreviation
```

### Verb Prefixes

- `install-` - Install new software or packages
- `configure-` - Configure existing software or system settings
- `setup-` - Install and configure together
- `toggle-` - Enable/disable a feature
- `fix-` - Apply fixes or workarounds
- `clean-` - Remove or clean up resources
- `update-` - Update existing software
- `backup-` - Create backups
- `restore-` - Restore from backups

## Configuration Files

### ISO and VM Configuration

```
iso/
├── disk.toml           # VM disk image configuration
├── iso.toml           # ISO image configuration
└── rclone/            # Cloud storage configuration
```

### Project Files

```
├── Containerfile      # Container build definition (capital C)
├── Justfile          # Just command definitions (capital J)
├── README.md         # Project documentation (all caps)
├── LICENSE           # License file (all caps)
└── .gitignore        # Git ignore rules (lowercase with dot)
```

## Directory Structure

### Standard Directories

```
├── ai/               # AI steering documentation
├── build/            # Build-time scripts
├── custom/           # Runtime customization
│   ├── brew/         # Homebrew Brewfiles
│   ├── flatpaks/     # Flatpak preinstall files
│   └── ujust/        # User just commands
├── iso/              # Image build configurations
└── .github/          # GitHub workflows and templates
```

### Naming Rules for Directories

- Use lowercase: `build/` ✅ not `Build/` ❌
- Use descriptive names: `flatpaks/` ✅ not `fp/` ❌
- Avoid spaces and special characters
- Use plural for collections: `flatpaks/` ✅ not `flatpak/` ❌

## Version and Branch Naming

### Git Branches

```bash
# ✅ Good branch names
main                   # Primary branch
feature/cosmic-desktop # Feature branches
fix/audio-issues      # Bug fix branches
docs/steering-update  # Documentation updates

# ❌ Bad branch names
master                # Use 'main' instead
dev                   # Too generic
fix_audio             # Underscore
FeatureCosmicDesktop  # CamelCase
```

### Image Tags

```bash
# ✅ Good image tags
stable                # Production release
latest                # Latest development
v1.0.0               # Semantic versioning
20241031             # Date-based versioning

# ❌ Bad image tags
prod                 # Abbreviation
STABLE               # All caps
v1                   # Incomplete version
```

## File Extensions

### Required Extensions

- Shell scripts: `.sh`
- Brewfiles: `.Brewfile` (capital B)
- Flatpak preinstall: `.preinstall`
- ujust files: `.just`
- Documentation: `.md`
- Configuration: `.toml`, `.yml`, `.yaml`

### Case Sensitivity

- Most extensions are lowercase: `.sh`, `.md`, `.toml`
- Exception: `.Brewfile` uses capital B (Homebrew convention)

## Special Cases

### Example Files

Add `.example` suffix to example files:

```
build/
├── 20-onepassword.sh.example    # Example script
├── 30-cosmic-desktop.sh.example # Example desktop replacement
```

### Disabled Files

Add `.disabled` suffix to temporarily disable files:

```
build/
├── 20-nvidia-driver.sh.disabled # Temporarily disabled
```

### Backup Files

Use timestamp suffix for backups:

```
backup-20241031-143022/
├── original-file.sh
└── modified-file.sh
```

## Validation

### Automated Checks

The project includes validation for:

- Shell script syntax (shellcheck)
- Brewfile syntax (brew bundle check)
- Just file syntax (just --check)
- File naming conventions (custom scripts)

### Manual Verification

Before committing, verify:

- File names follow conventions
- Extensions are correct
- No spaces or special characters in names
- Consistent case usage
- Descriptive, not abbreviated names

## Tools and Automation

### Renaming Scripts

```bash
# Rename files to follow conventions
for file in *.sh; do
    new_name=$(echo "$file" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    if [[ "$file" != "$new_name" ]]; then
        mv "$file" "$new_name"
    fi
done
```

### Validation Script

```bash
#!/bin/bash
# Check file naming conventions

errors=0

# Check build scripts
for file in build/*.sh; do
    if [[ ! "$file" =~ ^build/[0-9]{2}-[a-z-]+\.sh$ ]]; then
        echo "ERROR: $file doesn't follow naming convention"
        ((errors++))
    fi
done

# Check Brewfiles
for file in custom/brew/*.Brewfile; do
    if [[ ! "$file" =~ ^custom/brew/[a-z-]+\.Brewfile$ ]]; then
        echo "ERROR: $file doesn't follow naming convention"
        ((errors++))
    fi
done

exit $errors
```
