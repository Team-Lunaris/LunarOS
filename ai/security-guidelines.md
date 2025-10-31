# Security Guidelines

## Overview

Security is paramount in LunarOS development. This document outlines security best practices, requirements, and guidelines for all aspects of the project.

## Build-Time Security

### Package Sources

#### Trusted Repositories Only

```bash
# ✅ Trusted sources
dnf5 install -y package-name                    # Official Fedora repos
copr_install_isolated "ublue-os/staging" pkg    # Universal Blue COPR

# ❌ Untrusted sources
curl https://random-site.com/install.sh | bash  # Never do this
wget -O- http://untrusted.com/key | rpm --import # HTTP, not HTTPS
```

#### GPG Key Verification

```bash
# ✅ Proper GPG key handling
# Import from HTTPS source
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Verify key fingerprint (when possible)
gpg --show-keys --with-fingerprint key.asc

# ❌ Insecure key handling
rpm --import http://example.com/key.asc          # HTTP not HTTPS
rpm --import key.asc                             # Local file without verification
```

#### Repository Configuration

```bash
# ✅ Secure repository configuration
cat > /etc/yum.repos.d/example.repo << 'EOF'
[example]
name=Example Repository
baseurl=https://example.com/rpm/stable/$basearch  # HTTPS only
enabled=1
gpgcheck=1                                        # Always verify signatures
gpgkey=https://example.com/signing-key.pub       # HTTPS key source
repo_gpgcheck=1                                   # Verify repo metadata
EOF

# ❌ Insecure repository configuration
cat > /etc/yum.repos.d/bad.repo << 'EOF'
[bad]
baseurl=http://example.com/rpm/                   # HTTP not HTTPS
gpgcheck=0                                        # No signature verification
EOF
```

### Input Validation

#### Script Parameters

```bash
# ✅ Validate all inputs
validate_package_name() {
    local package="$1"

    # Check for valid package name format
    if [[ ! "$package" =~ ^[a-zA-Z0-9._+-]+$ ]]; then
        echo "ERROR: Invalid package name: $package"
        exit 1
    fi

    # Check length
    if [[ ${#package} -gt 100 ]]; then
        echo "ERROR: Package name too long"
        exit 1
    fi
}

# ❌ No input validation
dnf5 install -y "$USER_INPUT"  # Dangerous - could be malicious
```

#### File Path Validation

```bash
# ✅ Validate file paths
validate_file_path() {
    local path="$1"

    # Prevent directory traversal
    if [[ "$path" =~ \.\. ]]; then
        echo "ERROR: Path contains directory traversal"
        exit 1
    fi

    # Ensure path is within expected directory
    if [[ ! "$path" =~ ^/usr/share/ublue-os/ ]]; then
        echo "ERROR: Path outside allowed directory"
        exit 1
    fi
}
```

### Temporary File Security

#### Secure Temporary Files

```bash
# ✅ Secure temporary file creation
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Set restrictive permissions
chmod 600 "$TEMP_FILE"

# ❌ Insecure temporary files
TEMP_FILE="/tmp/myfile"        # Predictable name
echo "data" > /tmp/config      # World-readable
```

#### Cleanup Requirements

```bash
# ✅ Always clean up
#!/usr/bin/bash
set -euo pipefail

# Set up cleanup trap
cleanup() {
    rm -f /tmp/temp-repo.repo
    rm -f /tmp/temp-key.asc
}
trap cleanup EXIT

# Your script here

# ❌ No cleanup
# Leaves sensitive files on disk
```

## Runtime Security

### User Permissions

#### Principle of Least Privilege

```just
# ✅ Use sudo only when necessary
configure-service:
    #!/usr/bin/bash
    # User operations (no sudo)
    brew install package-name

    # System operations (sudo required)
    sudo systemctl enable service-name

# ❌ Unnecessary sudo usage
install-user-app:
    sudo brew install package-name  # Homebrew doesn't need sudo
```

#### Permission Validation

```just
# ✅ Check permissions before operations
secure-operation:
    #!/usr/bin/bash

    # Check if running as root when needed
    if [[ $EUID -ne 0 ]] && [[ "$1" == "--system" ]]; then
        echo "ERROR: System operations require root privileges"
        exit 1
    fi

    # Check if NOT running as root when inappropriate
    if [[ $EUID -eq 0 ]] && [[ "$1" == "--user" ]]; then
        echo "ERROR: User operations should not run as root"
        exit 1
    fi
```

### Input Sanitization

#### User Input Validation

```just
# ✅ Validate and sanitize user input
configure-git:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    read -p "Enter your name: " GIT_NAME
    read -p "Enter your email: " GIT_EMAIL

    # Validate name (letters, spaces, hyphens only)
    if [[ ! "$GIT_NAME" =~ ^[a-zA-Z\ \-]+$ ]]; then
        echo "ERROR: Invalid name format"
        exit 1
    fi

    # Validate email format
    if [[ ! "$GIT_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "ERROR: Invalid email format"
        exit 1
    fi

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

# ❌ No input validation
bad-git-config:
    read -p "Name: " NAME
    git config --global user.name "$NAME"  # Could contain malicious content
```

#### Command Injection Prevention

```bash
# ✅ Prevent command injection
safe_package_install() {
    local package="$1"

    # Validate package name
    if [[ ! "$package" =~ ^[a-zA-Z0-9._+-]+$ ]]; then
        echo "ERROR: Invalid package name"
        return 1
    fi

    # Use array to prevent injection
    local cmd=(brew install "$package")
    "${cmd[@]}"
}

# ❌ Vulnerable to command injection
unsafe_install() {
    local package="$1"
    brew install $package  # No quotes - vulnerable to injection
}
```

## Network Security

### HTTPS Requirements

#### Always Use HTTPS

```bash
# ✅ Secure downloads
curl -fsSL https://example.com/install.sh | bash
wget https://example.com/file.tar.gz

# ❌ Insecure downloads
curl -fsSL http://example.com/install.sh | bash   # HTTP not HTTPS
wget --no-check-certificate https://bad.com/file  # Ignores cert errors
```

#### Certificate Validation

```bash
# ✅ Verify certificates
curl --fail --show-error --location https://example.com/file

# ❌ Skip certificate validation
curl --insecure https://example.com/file          # Dangerous
wget --no-check-certificate https://example.com/  # Dangerous
```

### Repository Security

#### Verify Repository Signatures

```bash
# ✅ Enable signature verification
cat > /etc/yum.repos.d/secure.repo << 'EOF'
[secure]
name=Secure Repository
baseurl=https://secure.example.com/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://secure.example.com/key.pub
EOF

# ❌ Disable signature verification
cat > /etc/yum.repos.d/insecure.repo << 'EOF'
[insecure]
gpgcheck=0        # Dangerous
repo_gpgcheck=0   # Dangerous
EOF
```

## Secrets Management

### No Hardcoded Secrets

#### Environment Variables

```bash
# ✅ Use environment variables for secrets
if [[ -z "$API_KEY" ]]; then
    echo "ERROR: API_KEY environment variable not set"
    exit 1
fi

curl -H "Authorization: Bearer $API_KEY" https://api.example.com/

# ❌ Hardcoded secrets
API_KEY="secret123"  # Never do this
curl -H "Authorization: Bearer secret123" https://api.example.com/
```

#### GitHub Secrets

```yaml
# ✅ Use GitHub Secrets in workflows
- name: Sign image
  env:
    SIGNING_SECRET: ${{ secrets.SIGNING_SECRET }}
  run: cosign sign --key env://SIGNING_SECRET image

# ❌ Hardcoded secrets in workflows
- name: Bad example
  run: cosign sign --key "hardcoded-key" image
```

### Key Management

#### Cosign Key Handling

```bash
# ✅ Proper key handling
# Generate keys securely
cosign generate-key-pair

# Store private key in GitHub Secrets
# Commit only public key to repository

# ❌ Insecure key handling
# Never commit private keys
git add cosign.key  # NEVER DO THIS
```

## Container Security

### Base Image Security

#### Use Official Images

```dockerfile
# ✅ Use official, maintained base images
FROM ghcr.io/ublue-os/bluefin:stable

# ❌ Use untrusted base images
FROM random-user/custom-image:latest
FROM scratch  # Unless you know what you're doing
```

#### Pin Image Versions

```dockerfile
# ✅ Pin to specific versions for production
FROM ghcr.io/ublue-os/bluefin:stable@sha256:abc123...

# ✅ Use stable tags for development
FROM ghcr.io/ublue-os/bluefin:stable

# ❌ Use latest tag in production
FROM ghcr.io/ublue-os/bluefin:latest
```

### Runtime Security

#### Minimal Privileges

```dockerfile
# ✅ Run as non-root when possible
USER 1000:1000

# ❌ Run as root unnecessarily
USER root  # Only when absolutely necessary
```

#### Security Scanning

```yaml
# Include security scanning in CI/CD
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE_NAME }}:${{ env.TAG }}
```

## Dependency Security

### Package Verification

#### Verify Package Sources

```bash
# ✅ Verify package authenticity
dnf5 info package-name  # Check package details
rpm -qi package-name    # Verify installed package

# Check package signatures
rpm --checksig package.rpm
```

#### Dependency Scanning

```bash
# ✅ Regular dependency updates
# Use Renovate for automated dependency updates
# Review dependency changes in PRs
# Monitor security advisories
```

### Supply Chain Security

#### SBOM Generation

```yaml
# ✅ Generate Software Bill of Materials
- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    image: ${{ env.IMAGE_NAME }}:${{ env.TAG }}
```

#### Provenance Tracking

```yaml
# ✅ Track build provenance
- name: Generate provenance
  uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v1.4.0
```

## Validation and Testing

### Security Testing

#### Static Analysis

```bash
# ✅ Use security linting tools
shellcheck build/*.sh           # Shell script analysis
hadolint Containerfile         # Dockerfile linting
```

#### Runtime Testing

```bash
# ✅ Test security configurations
# Verify file permissions
ls -la /etc/sensitive-file

# Check service configurations
systemctl show service-name

# Validate network configurations
ss -tulpn
```

### Penetration Testing

#### Regular Security Audits

- Review all external dependencies
- Audit file permissions and ownership
- Test input validation
- Verify network security
- Check for privilege escalation vectors

## Incident Response

### Security Issue Handling

#### Immediate Response

1. **Assess Impact** - Determine scope and severity
2. **Contain** - Prevent further damage
3. **Investigate** - Identify root cause
4. **Remediate** - Apply fixes
5. **Document** - Record lessons learned

#### Communication

- Report security issues privately first
- Use GitHub Security Advisories for disclosure
- Coordinate with Universal Blue team if needed
- Provide clear remediation steps

### Vulnerability Disclosure

#### Responsible Disclosure

```markdown
# Security Policy

## Reporting Security Issues

Please report security vulnerabilities to:

- Email: security@example.com
- GitHub Security Advisory (private)

Do not report security issues in public GitHub issues.

## Response Timeline

- Initial response: 24 hours
- Assessment: 72 hours
- Fix deployment: 7 days (critical), 30 days (others)
```

## Compliance and Standards

### Security Standards

#### Follow Industry Best Practices

- NIST Cybersecurity Framework
- CIS Controls
- OWASP Security Guidelines
- Container Security Standards

#### Regular Updates

- Keep base images updated
- Apply security patches promptly
- Monitor security advisories
- Update dependencies regularly

### Documentation Requirements

#### Security Documentation

- Document all security decisions
- Maintain threat model
- Record security configurations
- Update security procedures

#### Change Management

- Security review for all changes
- Approval process for security-sensitive modifications
- Rollback procedures for security incidents
