#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_FILE="$REPO_ROOT/config/packages/base.txt"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/package.sh"

atlas_detect_system
atlas_package_require_supported

if [[ ! -f "$PACKAGE_FILE" ]]; then
    atlas_error "Package manifest not found: $PACKAGE_FILE"
    exit 1
fi

packages=()
installed_packages=()
missing_packages=()

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

for package in "${packages[@]}"; do
    if atlas_package_is_installed "$package"; then
        installed_packages+=("$package")
        atlas_success "$package already installed"
    else
        missing_packages+=("$package")
        atlas_step "$package requires installation"
    fi
done

if [[ "${#missing_packages[@]}" -gt 0 ]]; then
    atlas_package_update
    atlas_package_install "${missing_packages[@]}"

    for package in "${missing_packages[@]}"; do
        atlas_success "$package installed"
    done
else
    atlas_success "All requested packages are already installed"
fi

echo
atlas_info "Requested: ${#packages[@]}"
atlas_info "Already installed: ${#installed_packages[@]}"
atlas_info "Installed now: ${#missing_packages[@]}"

atlas_success "Base package installation complete"
