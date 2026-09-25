#!/bin/sh
# Install script for cipherowl-sr3 CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/cipherowl-ai/cipherowl-sr3/main/scripts/install-sr3.sh | sh
#
# Environment variables:
#   VERSION   - specific version to install (default: latest)
#   INSTALL_DIR - installation directory (default: ~/.local/bin)

set -eu

REPO="cipherowl-ai/cipherowl-sr3"
BINARY="cipherowl-sr3"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${VERSION:-}"

fail() {
    echo "Error: $*" >&2
    exit 1
}

fetch() {
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
        --connect-timeout 10 --max-time 120 -fsSL "$@"
}

command -v curl >/dev/null 2>&1 || fail "curl is required"
if command -v sha256sum >/dev/null 2>&1; then
    CHECKSUM_TOOL=sha256sum
elif command -v shasum >/dev/null 2>&1; then
    CHECKSUM_TOOL=shasum
else
    fail "sha256sum or shasum is required for checksum verification"
fi

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    darwin) OS="darwin" ;;
    linux)  OS="linux" ;;
    *)      fail "unsupported OS: $OS" ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)             fail "unsupported architecture: $ARCH" ;;
esac

# Resolve version
if [ -z "$VERSION" ]; then
    LATEST_URL=$(fetch -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest") ||
        fail "could not determine latest version; set VERSION explicitly"
    case "$LATEST_URL" in
        "https://github.com/${REPO}/releases/tag/"*) VERSION=${LATEST_URL##*/} ;;
        *) fail "unexpected latest-release URL; set VERSION explicitly" ;;
    esac
fi
printf '%s\n' "$VERSION" | grep -Eq '^[0-9]{4}\.[1-9][0-9]*\.(0|[1-9][0-9]*)$' ||
    fail "VERSION must be YYYY.MINOR.PATCH without a v prefix"

case "$INSTALL_DIR" in
    /*) ;;
    *) INSTALL_DIR="$PWD/$INSTALL_DIR" ;;
esac

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY}-${OS}-${ARCH}"

echo "Installing ${BINARY} ${VERSION} (${OS}/${ARCH})..."
echo "  From: ${DOWNLOAD_URL}"
echo "  To:   ${INSTALL_DIR}/${BINARY}"

# Keep the existing installation intact until both downloads are verified.
TMP=$(mktemp -d "${TMPDIR:-/tmp}/cipherowl-sr3.XXXXXX")
STAGED=""
cleanup() {
    rm -f "$TMP/binary" "$TMP/checksum"
    [ -z "$STAGED" ] || rm -f "$STAGED"
    rmdir "$TMP"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
fetch -o "$TMP/binary" "$DOWNLOAD_URL" || fail "binary download failed"
[ -s "$TMP/binary" ] || fail "downloaded binary is empty"

# Verify checksum
fetch -o "$TMP/checksum" "${DOWNLOAD_URL}.sha256" || fail "checksum download failed; refusing unverified installation"
EXPECTED=$(awk 'NF { count++; digest=$1 } END { if (count != 1) exit 1; print digest }' "$TMP/checksum") ||
    fail "malformed checksum file"
printf '%s\n' "$EXPECTED" | grep -Eq '^[[:xdigit:]]{64}$' || fail "malformed SHA-256 checksum"
EXPECTED=$(printf '%s' "$EXPECTED" | tr '[:upper:]' '[:lower:]')
if [ "$CHECKSUM_TOOL" = sha256sum ]; then
    ACTUAL=$(sha256sum "$TMP/binary") || fail "checksum calculation failed"
else
    ACTUAL=$(shasum -a 256 "$TMP/binary") || fail "checksum calculation failed"
fi
ACTUAL=${ACTUAL%% *}
[ "$EXPECTED" = "$ACTUAL" ] || fail "checksum verification failed"
echo "  Checksum: verified"

# Install
mkdir -p "$INSTALL_DIR"
[ ! -d "${INSTALL_DIR}/${BINARY}" ] || fail "installation target is a directory"
STAGED=$(mktemp "${INSTALL_DIR}/.${BINARY}.XXXXXX")
cp "$TMP/binary" "$STAGED"
chmod 755 "$STAGED"
mv -f "$STAGED" "${INSTALL_DIR}/${BINARY}"
STAGED=""

INSTALLED="${INSTALL_DIR}/${BINARY}"
echo ""
echo "Installed ${BINARY} ${VERSION} to ${INSTALLED}"

# Leave shell configuration under the user's control.
case ":$PATH:" in
    *":${INSTALL_DIR}:"*) ;;
    *) echo "Add ${INSTALL_DIR} to your shell's PATH to invoke ${BINARY} by name." ;;
esac

echo ""
echo "Get started:"
echo "  ${INSTALLED} --version"
echo "  ${INSTALLED} --agent-info"
echo "Read --agent-info on first use and whenever the version changes before reusing saved commands."
