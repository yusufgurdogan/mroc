#!/bin/bash
#
# mroc installer script
# Usage: curl -sL https://getmroc.yusufgurdogan.com | bash
#    or: curl -sL https://raw.githubusercontent.com/yusufgurdogan/mroc/main/install.sh | bash
#

set -e

# Configuration - update these for your fork
GITHUB_REPO="yusufgurdogan/mroc"
BINARY_NAME="mroc"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_banner() {
    echo ""
    echo "  _ __ ___  _ __ ___   ___ "
    echo " | '_ \` _ \\| '__/ _ \\ / __|"
    echo " | | | | | | | | (_) | (__ "
    echo " |_| |_| |_|_|  \\___/ \\___|"
    echo ""
    echo " Secure file transfer"
    echo ""
}

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

# Detect OS
detect_os() {
    OS="$(uname -s)"
    case "$OS" in
        Linux*)     OS_NAME="Linux" ;;
        Darwin*)    OS_NAME="macOS" ;;
        FreeBSD*)   OS_NAME="FreeBSD" ;;
        NetBSD*)    OS_NAME="NetBSD" ;;
        OpenBSD*)   OS_NAME="OpenBSD" ;;
        DragonFly*) OS_NAME="DragonFlyBSD" ;;
        CYGWIN*|MINGW*|MSYS*) OS_NAME="Windows" ;;
        *)          error "Unsupported operating system: $OS" ;;
    esac
}

# Detect architecture
detect_arch() {
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64)   ARCH_NAME="64bit" ;;
        i386|i686)      ARCH_NAME="32bit" ;;
        armv5*)         ARCH_NAME="ARMv5" ;;
        armv6*|armv7*)  ARCH_NAME="ARM" ;;
        aarch64|arm64)  ARCH_NAME="ARM64" ;;
        riscv64)        ARCH_NAME="RISCV64" ;;
        *)              error "Unsupported architecture: $ARCH" ;;
    esac
}

# Get latest release version from GitHub
get_latest_version() {
    VERSION=$(curl -sL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        error "Could not determine latest version. Check your internet connection."
    fi
}

# Download and install
install_mroc() {
    print_banner

    echo "Detecting system..."
    detect_os
    detect_arch
    echo "  OS: $OS_NAME"
    echo "  Arch: $ARCH_NAME"

    echo "Fetching latest version..."
    get_latest_version
    echo "  Version: $VERSION"

    # Construct download URL
    if [ "$OS_NAME" = "Windows" ]; then
        EXT="zip"
        ARCHIVE_NAME="${BINARY_NAME}_${VERSION}_${OS_NAME}-${ARCH_NAME}.${EXT}"
    else
        EXT="tar.gz"
        ARCHIVE_NAME="${BINARY_NAME}_${VERSION}_${OS_NAME}-${ARCH_NAME}.${EXT}"
    fi

    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"

    echo "Downloading ${BINARY_NAME}..."
    echo "  URL: $DOWNLOAD_URL"

    # Create temp directory
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT

    # Download
    if command -v curl &> /dev/null; then
        curl -sL "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE_NAME" || error "Download failed"
    elif command -v wget &> /dev/null; then
        wget -q "$DOWNLOAD_URL" -O "$TMP_DIR/$ARCHIVE_NAME" || error "Download failed"
    else
        error "Neither curl nor wget found. Please install one of them."
    fi

    # Extract
    echo "Extracting..."
    cd "$TMP_DIR"
    if [ "$EXT" = "zip" ]; then
        unzip -q "$ARCHIVE_NAME" || error "Extraction failed"
    else
        tar -xzf "$ARCHIVE_NAME" || error "Extraction failed"
    fi

    # Install
    echo "Installing to $INSTALL_DIR..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "$BINARY_NAME" "$INSTALL_DIR/"
    else
        warn "Need sudo to install to $INSTALL_DIR"
        sudo mv "$BINARY_NAME" "$INSTALL_DIR/"
    fi

    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    success ""
    success "Successfully installed ${BINARY_NAME} ${VERSION}!"
    success ""
    echo "Run '${BINARY_NAME} --help' to get started."
    echo ""
}

# Run installer
install_mroc
