#!/usr/bin/env bash
set -euo pipefail

# OpenClaw Android installer
# Repo: YatharthDixit/test-claw-and

REPO_OWNER="YatharthDixit"
REPO_NAME="test-claw-and"
BRANCH="main"

RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
INSTALL_DIR="$HOME/.openclaw-android"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "══════════════════════════════════════════════"
echo "  OpenClaw Android Installer"
echo "══════════════════════════════════════════════"
echo ""

mkdir -p "$INSTALL_DIR/patches"
cd "$INSTALL_DIR"

download_file() {
    local url="$1"
    local output="$2"

    echo -e "  ${YELLOW}Downloading:${NC} $output"

    if curl -fsSL --connect-timeout 15 --max-time 180 "$url" -o "$output"; then
        return 0
    fi

    echo -e "  ${YELLOW}[WARN]${NC} GitHub raw failed, trying mirrors..."

    local mirrors=(
        "https://ghfast.top/$url"
        "https://ghproxy.net/$url"
        "https://mirror.ghproxy.com/$url"
    )

    for mirror in "${mirrors[@]}"; do
        echo "    trying mirror..."
        if curl -fsSL --connect-timeout 15 --max-time 180 "$mirror" -o "$output"; then
            echo -e "  ${GREEN}✓${NC} Downloaded via mirror"
            return 0
        fi
    done

    echo -e "  ${RED}✗${NC} Failed to download $output"
    exit 1
}

# Download main setup script
download_file "$RAW_BASE/post-setup.sh" "post-setup.sh"
chmod +x post-setup.sh

# Optional files used by post-setup.sh
download_file "$RAW_BASE/oa.sh" "oa.sh" || true
chmod +x oa.sh 2>/dev/null || true

download_file "$RAW_BASE/patches/glibc-compat.js" "patches/glibc-compat.js" || true

echo ""
echo -e "${GREEN}✓ Files downloaded${NC}"
echo ""
echo "Starting OpenClaw Android post-setup..."
echo ""

bash "$INSTALL_DIR/post-setup.sh"
