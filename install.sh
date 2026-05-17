#!/usr/bin/env bash
set -euo pipefail

# OpenClaw Android installer
# Repo: YatharthDixit/test-claw-and
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YatharthDixit/test-claw-and/main/install.sh | sed 's/\r$//' | bash

REPO_OWNER="YatharthDixit"
REPO_NAME="test-claw-and"
BRANCH="main"

RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
INSTALL_DIR="${HOME}/.openclaw-android"

MAIN_SCRIPT_REMOTE="openclaw-android-post-setup-fixed.sh"
MAIN_SCRIPT_LOCAL="openclaw-android-post-setup-fixed.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "══════════════════════════════════════════════"
echo "  OpenClaw Android Installer"
echo "══════════════════════════════════════════════"
echo ""

need_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} Missing command: $cmd"
        exit 1
    fi
}

need_cmd curl
need_cmd bash

mkdir -p "$INSTALL_DIR/patches"
cd "$INSTALL_DIR"

download_required() {
    local url="$1"
    local output="$2"

    echo -e "  ${YELLOW}Downloading:${NC} $output"

    if curl -fsSL --connect-timeout 15 --max-time 180 "$url" -o "$output"; then
        sed -i 's/\r$//' "$output" 2>/dev/null || true
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
            sed -i 's/\r$//' "$output" 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Downloaded via mirror"
            return 0
        fi
    done

    echo -e "  ${RED}✗${NC} Failed to download required file: $output"
    exit 1
}

download_optional() {
    local url="$1"
    local output="$2"

    echo -e "  ${YELLOW}Downloading optional:${NC} $output"

    if curl -fsSL --connect-timeout 15 --max-time 180 "$url" -o "$output"; then
        sed -i 's/\r$//' "$output" 2>/dev/null || true
        return 0
    fi

    local mirrors=(
        "https://ghfast.top/$url"
        "https://ghproxy.net/$url"
        "https://mirror.ghproxy.com/$url"
    )

    for mirror in "${mirrors[@]}"; do
        if curl -fsSL --connect-timeout 15 --max-time 180 "$mirror" -o "$output"; then
            sed -i 's/\r$//' "$output" 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Optional file downloaded via mirror"
            return 0
        fi
    done

    echo -e "  ${YELLOW}[WARN]${NC} Optional file missing: $output"
    return 0
}

# Download your actual fixed setup script
download_required "$RAW_BASE/$MAIN_SCRIPT_REMOTE" "$MAIN_SCRIPT_LOCAL"
chmod +x "$MAIN_SCRIPT_LOCAL"

# Optional helper files, only if present in repo
download_optional "$RAW_BASE/oa.sh" "oa.sh"
chmod +x oa.sh 2>/dev/null || true

download_optional "$RAW_BASE/patches/glibc-compat.js" "patches/glibc-compat.js"

echo ""
echo -e "${GREEN}✓ Installer files ready${NC}"
echo ""
echo "Starting OpenClaw Android post-setup..."
echo ""

bash "$INSTALL_DIR/$MAIN_SCRIPT_LOCAL"
