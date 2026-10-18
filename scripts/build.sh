#!/usr/bin/env bash
set -e

# ==============================================================================
# Veyra OS — Local Build Script
# Run inside Debian / Ubuntu or WSL2 with sudo privileges.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIVE_BUILD_DIR="$PROJECT_ROOT/live-build"

echo "=== Veyra OS Live Build Engine ==="
echo "Target: HP Folio 13 / x86_64 Safe Live USB"
echo "Working directory: $LIVE_BUILD_DIR"

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (or with sudo) to set up chroot/loop devices."
  exit 1
fi

# Ensure required utilities exist
for tool in lb debootstrap xorriso; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing required dependency: $tool. Installing..."
    apt-get update && apt-get install -y live-build debootstrap xorriso
    break
  fi
done

cd "$LIVE_BUILD_DIR"
chmod +x auto/*

echo "--> Purging prior build caches..."
lb clean --purge

echo "--> Initializing Debian Live configuration..."
lb config

echo "--> Commencing ISO compilation (this will take several minutes)..."
lb build

echo "=== Build Complete ==="
ls -lh *.iso
