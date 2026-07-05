#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_FILE="$REPO_ROOT/config/packages/base.txt"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/package.sh"

atlas_detect_system

if [[ ! -f "$PACKAGE_FILE" ]]; then
    atlas_error "Package manifest not found: $PACKAGE_FILE"
    exit 1
fi

packages=()

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"

    if [[ -n "$line" ]]; then
        packages+=("$line")
    fi
done < "$PACKAGE_FILE"

if [[ "${#packages[@]}" -eq 0 ]]; then
    atlas_warn "No packages found in package manifest."
    exit 0
fi

atlas_info "Package manifest: $PACKAGE_FILE"
atlas_info "Packages requested: ${#packages[@]}"

atlas_package_update

for package in "${packages[@]}"; do
    atlas_package_install "$package"
done

atlas_success "Base package installation complete"
