# Testing Procedures

## Overview

Comprehensive testing ensures LunarOS changes work correctly and don't break existing functionality. This document outlines testing procedures for all aspects of the project.

## Local Development Testing

### Prerequisites

#### Required Tools

```bash
# Install development dependencies
sudo dnf install -y just podman qemu-kvm

# Verify tools are working
just --version
podman --version
```

#### System Requirements

- **Podman** - Container building and management
- **QEMU/KVM** - Virtual machine testing
- **Just** - Command runner for build tasks
- **Git** - Version control
- **Sufficient disk space** - At least 20GB free for builds and VMs

### Build Testing

#### Container Image Build

```bash
# Basic build test
just build

# Build with specific tag
just build localhost/lunaros test

# Verify build succeeded
podman images localhost/lunaros
```

#### Build Script Validation

```bash
# Test individual build scripts
chmod +x build/20-new-script.sh
shellcheck build/20-new-script.sh

# Test script in container context (advanced)
podman run --rm -it \
  --mount type=bind,source=$(pwd),target=/ctx \
  ghcr.io/ublue-os/bluefin:stable \
  /ctx/build/20-new-script.sh
```

### Virtual Machine Testing

#### QCOW2 VM Testing

```bash
# Build VM image
just build-qcow2

# Run VM in browser interface
just run-vm-qcow2

# Access VM at http://localhost:8006 (port may vary)
```

#### ISO Testing

```bash
# Build ISO image
just build-iso

# Run ISO in VM
just run-vm-iso
```

#### VM Testing Checklist

- [ ] System boots successfully
- [ ] Desktop environment loads
- [ ] Network connectivity works
- [ ] Flatpaks install correctly
- [ ] ujust commands function
- [ ] Homebrew installation works
- [ ] System updates properly

### Component Testing

#### Brewfile Testing

```bash
# Validate Brewfile syntax
brew bundle check --file custom/brew/default.Brewfile

# Test installation (requires Homebrew)
brew bundle --file custom/brew/default.Brewfile --dry-run
```

#### Flatpak Testing

```bash
# Verify Flatpak IDs exist
flatpak search org.mozilla.firefox

# Test preinstall file format
# (No direct validation tool, manual review required)
```

#### ujust Command Testing

```bash
# Test just file syntax
just --justfile custom/ujust/custom-apps.just --list

# Test specific commands
just --justfile custom/ujust/custom-apps.just install-dev-tools
```

## Automated Testing

### GitHub Actions Validation

#### Pre-commit Checks

The repository includes automated validation:

- **Shellcheck** - Shell script linting
- **Brewfile validation** - Homebrew syntax checking
- **Just syntax** - Just file validation
- **Flatpak verification** - Verify Flatpak IDs exist

#### Pull Request Testing

```yaml
# .github/workflows/build.yml includes:
- Build validation
- Syntax checking
- Test image creation
- Security scanning (if enabled)
```

### Local Pre-commit Testing

#### Run All Validations

```bash
# Lint shell scripts
just lint

# Format shell scripts
just format

# Check Just syntax
just check

# Fix Just syntax
just fix
```

#### Individual Validations

```bash
# Shell script linting
find . -name "*.sh" -exec shellcheck {} \;

# Brewfile validation
for file in custom/brew/*.Brewfile; do
  brew bundle check --file "$file"
done

# Just file validation
find custom/ujust -name "*.just" -exec just --justfile {} --list \;
```

## Integration Testing

### End-to-End Testing

#### Complete Workflow Test

1. **Build Image**

   ```bash
   just build localhost/lunaros test
   ```

2. **Create VM**

   ```bash
   just build-qcow2 localhost/lunaros test
   ```

3. **Boot and Test**

   ```bash
   just run-vm-qcow2 localhost/lunaros test
   ```

4. **Verify Functionality**
   - Boot to desktop
   - Run `ujust` commands
   - Install Homebrew packages
   - Verify Flatpaks installed
   - Test system updates

#### Deployment Testing

```bash
# Test bootc switch (on existing bootc system)
sudo bootc switch localhost/lunaros:test
sudo systemctl reboot

# After reboot, verify:
ujust --help
brew --version
flatpak list
```

### Regression Testing

#### Core Functionality Tests

```bash
# Test essential commands work
ujust install-default-apps
ujust configure-system
ujust maintenance

# Test package managers
brew install bat
flatpak install flathub org.gnome.Calculator

# Test system operations
sudo bootc upgrade --check
podman run hello-world
```

#### Performance Testing

```bash
# Boot time measurement
systemd-analyze

# Resource usage
free -h
df -h
```

## Testing Scenarios

### New Build Script Testing

#### Script Development Process

1. **Create Script**

   ```bash
   # Create new build script
   cp build/20-onepassword.sh.example build/25-new-software.sh
   # Edit script for your needs
   ```

2. **Validate Script**

   ```bash
   # Check syntax
   shellcheck build/25-new-software.sh

   # Test execution permissions
   chmod +x build/25-new-software.sh
   ```

3. **Test in Container**

   ```bash
   # Build image with new script
   just build localhost/lunaros test-new-software

   # Verify software installed
   podman run --rm localhost/lunaros:test-new-software which new-command
   ```

4. **Test in VM**
   ```bash
   # Create and test VM
   just build-qcow2 localhost/lunaros test-new-software
   just run-vm-qcow2 localhost/lunaros test-new-software
   ```

### Brewfile Testing

#### New Brewfile Process

1. **Create Brewfile**

   ```bash
   # Create new category
   cat > custom/brew/gaming.Brewfile << 'EOF'
   brew "steam"
   brew "lutris"
   EOF
   ```

2. **Validate Syntax**

   ```bash
   brew bundle check --file custom/brew/gaming.Brewfile
   ```

3. **Test Installation**

   ```bash
   # Dry run test
   brew bundle --file custom/brew/gaming.Brewfile --dry-run

   # Full test (if Homebrew available)
   brew bundle --file custom/brew/gaming.Brewfile
   ```

4. **Create ujust Command**

   ```just
   [group('Apps')]
   install-gaming-tools:
       brew bundle --file /usr/share/ublue-os/homebrew/gaming.Brewfile
   ```

5. **Test Complete Workflow**

   ```bash
   # Build image with new Brewfile
   just build

   # Test in VM
   just build-qcow2
   just run-vm-qcow2

   # In VM: ujust install-gaming-tools
   ```

### Flatpak Testing

#### New Preinstall File Process

1. **Create Preinstall File**

   ```ini
   # custom/flatpaks/gaming.preinstall
   [Flatpak Preinstall com.valvesoftware.Steam]
   Branch=stable

   [Flatpak Preinstall org.lutris.Lutris]
   Branch=stable
   ```

2. **Verify Applications Exist**

   ```bash
   flatpak search com.valvesoftware.Steam
   flatpak search org.lutris.Lutris
   ```

3. **Test in VM**

   ```bash
   # Build and test VM
   just build-qcow2
   just run-vm-qcow2

   # After first boot, verify applications installed
   flatpak list --app
   ```

### ujust Command Testing

#### New Command Development

1. **Create Command**

   ```just
   # In custom/ujust/custom-gaming.just
   [group('Gaming')]
   setup-gaming:
       #!/usr/bin/bash
       echo "Setting up gaming environment..."
       # Your commands here
   ```

2. **Test Syntax**

   ```bash
   just --justfile custom/ujust/custom-gaming.just --list
   ```

3. **Test Execution**

   ```bash
   just --justfile custom/ujust/custom-gaming.just setup-gaming
   ```

4. **Test in Built Image**

   ```bash
   # Build image
   just build

   # Test in VM
   just build-qcow2
   just run-vm-qcow2

   # In VM: ujust setup-gaming
   ```

## Error Testing

### Common Failure Scenarios

#### Build Failures

```bash
# Test with intentional errors
echo "invalid command" >> build/10-build.sh
just build  # Should fail

# Revert and test recovery
git checkout build/10-build.sh
just build  # Should succeed
```

#### Network Failures

```bash
# Test offline scenarios
# Disconnect network during build
# Verify graceful failure handling
```

#### Permission Failures

```bash
# Test permission scenarios
# Run commands without sudo when needed
# Verify appropriate error messages
```

### Error Recovery Testing

#### Rollback Testing

```bash
# Test bootc rollback functionality
sudo bootc rollback
sudo systemctl reboot

# Verify system returns to previous state
```

#### Cleanup Testing

```bash
# Test cleanup procedures
just clean
just sudo-clean

# Verify all build artifacts removed
```

## Performance Testing

### Build Performance

#### Build Time Measurement

```bash
# Measure build time
time just build

# Measure VM creation time
time just build-qcow2
```

#### Resource Usage

```bash
# Monitor during build
htop  # CPU and memory usage
iotop # Disk I/O
```

### Runtime Performance

#### Boot Time Analysis

```bash
# In VM after boot
systemd-analyze
systemd-analyze blame
systemd-analyze critical-chain
```

#### Resource Consumption

```bash
# Check resource usage
free -h        # Memory usage
df -h          # Disk usage
lscpu          # CPU information
```

## Security Testing

### Vulnerability Scanning

#### Container Scanning

```bash
# Scan built image for vulnerabilities
podman run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image localhost/lunaros:latest
```

#### Dependency Scanning

```bash
# Check for known vulnerabilities in dependencies
# Review Renovate PRs for security updates
```

### Permission Testing

#### File Permissions

```bash
# Verify correct file permissions
find /usr/share/ublue-os -type f -exec ls -la {} \;

# Check for world-writable files
find / -type f -perm -002 2>/dev/null
```

#### Service Security

```bash
# Check service configurations
systemctl show service-name
systemctl cat service-name
```

## Documentation Testing

### Documentation Validation

#### Link Testing

```bash
# Test all links in documentation
# Use tools like markdown-link-check
```

#### Example Testing

```bash
# Test all code examples in documentation
# Verify commands work as documented
```

### User Experience Testing

#### New User Workflow

1. Follow README instructions exactly
2. Test all documented commands
3. Verify expected outcomes
4. Document any issues or confusion

#### Command Documentation

```bash
# Test all ujust commands have proper help
ujust --help
ujust command-name --help  # If supported
```

## Continuous Integration

### GitHub Actions Testing

#### Workflow Validation

```yaml
# Test workflow changes locally with act
act -j build

# Or test specific steps
act -j build -s step-name
```

#### Secret Testing

```bash
# Verify secrets are properly configured
# Test signing workflow with test keys
```

### Release Testing

#### Pre-release Validation

1. Test complete build pipeline
2. Verify all automated checks pass
3. Test deployment to staging environment
4. Perform manual validation
5. Test rollback procedures

#### Post-release Validation

1. Verify images are published correctly
2. Test user deployment workflow
3. Monitor for issues
4. Validate update mechanisms

## Testing Checklist

### Before Committing

- [ ] All shell scripts pass shellcheck
- [ ] All Brewfiles validate successfully
- [ ] All ujust commands have correct syntax
- [ ] Local build completes successfully
- [ ] VM boots and functions correctly
- [ ] All new features work as expected
- [ ] No regressions in existing functionality
- [ ] Documentation updated for changes
- [ ] Security implications considered

### Before Merging PR

- [ ] All automated checks pass
- [ ] Manual testing completed
- [ ] Code review approved
- [ ] Documentation reviewed
- [ ] Breaking changes documented
- [ ] Migration path provided (if needed)

### Before Release

- [ ] Full integration testing completed
- [ ] Performance testing passed
- [ ] Security scanning completed
- [ ] Documentation updated
- [ ] Release notes prepared
- [ ] Rollback plan ready
