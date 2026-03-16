#!/bin/sh
# Install script for cipherowl-sr3 CLI
# Usage: curl -sSL https://raw.githubusercontent.com/cipherowl-ai/cipherowl-sr3/main/install.sh | sh
#
# Environment variables:
#   VERSION   - specific version to install (default: latest)
#   INSTALL_DIR - installation directory (default: ~/.local/bin)

set -e

REPO="cipherowl-ai/cipherowl-sr3"
BINARY="cipherowl-sr3"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    darwin) OS="darwin" ;;
    linux)  OS="linux" ;;
    *)      echo "Error: unsupported OS: $OS"; exit 1 ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)             echo "Error: unsupported architecture: $ARCH"; exit 1 ;;
esac

# Resolve version
if [ -z "$VERSION" ]; then
    VERSION=$(curl -sSL "https://api.github.com/repos/${REPO}/releases/latest" | awk -F'"' '/tag_name/ {print $4; exit}')
    if [ -z "$VERSION" ]; then
        echo "Error: could not determine latest version. Set VERSION explicitly."
        exit 1
    fi
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY}-${OS}-${ARCH}"

echo "Installing ${BINARY} ${VERSION} (${OS}/${ARCH})..."
echo "  From: ${DOWNLOAD_URL}"
echo "  To:   ${INSTALL_DIR}/${BINARY}"

# Download
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
HTTP_CODE=$(curl -sSL -w "%{http_code}" -o "$TMP" "$DOWNLOAD_URL")
if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: download failed (HTTP $HTTP_CODE)"
    echo "Check that version ${VERSION} exists at https://github.com/${REPO}/releases"
    exit 1
fi

# Verify checksum
SHA_URL="${DOWNLOAD_URL}.sha256"
SHA_HTTP=$(curl -sSL -w "%{http_code}" -o "${TMP}.sha256" "$SHA_URL")
if [ "$SHA_HTTP" = "200" ]; then
    EXPECTED=$(awk '{print $1}' "${TMP}.sha256")
    ACTUAL=$(shasum -a 256 "$TMP" | awk '{print $1}')
    rm -f "${TMP}.sha256"
    if [ "$EXPECTED" != "$ACTUAL" ]; then
        echo "Error: checksum verification failed"
        echo "  Expected: $EXPECTED"
        echo "  Actual:   $ACTUAL"
        exit 1
    fi
    echo "  Checksum: verified"
else
    rm -f "${TMP}.sha256"
    echo "  Checksum: not available (skipping verification)"
fi

# Install
mkdir -p "$INSTALL_DIR"
chmod +x "$TMP"
mv "$TMP" "${INSTALL_DIR}/${BINARY}"

echo ""
echo "Installed ${BINARY} ${VERSION} to ${INSTALL_DIR}/${BINARY}"

# Check if INSTALL_DIR is in PATH
case ":$PATH:" in
    *":${INSTALL_DIR}:"*) ;;
    *)
        echo ""
        echo "NOTE: ${INSTALL_DIR} is not in your PATH. Add it with:"
        echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
        echo "  echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc"
        ;;
esac

echo ""
echo "Get started:"
echo "  ${BINARY} login              # authenticate via browser"
echo "  ${BINARY} doctor             # verify connectivity"
echo "  ${BINARY} screen <address>   # screen an address"
echo "  ${BINARY} --help             # see all commands"
