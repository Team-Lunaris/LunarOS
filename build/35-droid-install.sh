#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# Install Factory CLI (droid) and ripgrep
###############################################################################
# Installs the droid CLI tool and ripgrep binary
###############################################################################

echo "::group:: Install Factory CLI (droid)"

# Detect platform and architecture
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$PLATFORM" in
    linux) PLATFORM="linux" ;;
    darwin) PLATFORM="darwin" ;;
    *) echo "Unsupported OS: $PLATFORM"; exit 1 ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64 | amd64) ARCH="x64" ;;
    arm64 | aarch64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Check AVX2 for x64 baseline support
ARCH_SUFFIX=""
if [ "$ARCH" = "x64" ]; then
    if [ "$PLATFORM" = "linux" ] && ! grep -qi avx2 /proc/cpuinfo 2>/dev/null; then
        ARCH_SUFFIX="-baseline"
    elif [ "$PLATFORM" = "darwin" ] && ! sysctl -a 2>/dev/null | grep -q "machdep.cpu.*AVX2"; then
        ARCH_SUFFIX="-baseline"
    fi
fi

# Download and verify checksum
DROID_VER="0.22.9"
BASE_URL="https://downloads.factory.ai"
DROID_URL="$BASE_URL/factory-cli/releases/$DROID_VER/$PLATFORM/$ARCH$ARCH_SUFFIX/droid"
RG_URL="$BASE_URL/ripgrep/$PLATFORM/$ARCH/rg"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading droid v$DROID_VER for $PLATFORM-$ARCH"
curl -fsSL -o "$TMPDIR/droid" "$DROID_URL"
curl -fsSL -o "$TMPDIR/droid.sha256" "$DROID_URL.sha256"

echo "Verifying droid checksum"
cd "$TMPDIR" && sha256sum -c droid.sha256 || exit 1
cd - > /dev/null

chmod +x "$TMPDIR/droid"

echo "Downloading ripgrep"
curl -fsSL -o "$TMPDIR/rg" "$RG_URL"
curl -fsSL -o "$TMPDIR/rg.sha256" "$RG_URL.sha256"

echo "Verifying ripgrep checksum"
cd "$TMPDIR" && sha256sum -c rg.sha256 || exit 1
cd - > /dev/null

chmod +x "$TMPDIR/rg"

# Install to system paths
mkdir -p /usr/local/bin /usr/local/lib/factory/bin
cp "$TMPDIR/droid" /usr/local/bin/droid
cp "$TMPDIR/rg" /usr/local/lib/factory/bin/rg

echo "Factory CLI v$DROID_VER installed successfully"

echo "::endgroup::"
