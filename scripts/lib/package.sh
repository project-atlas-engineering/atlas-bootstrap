#!/usr/bin/env bash

# Package management helpers for Atlas Bootstrap.

atlas_package_require_supported() {
    if [[ "${ATLAS_PACKAGE_MANAGER:-unknown}" != "apt" ]]; then
        atlas_error "Unsupported package manager: ${ATLAS_PACKAGE_MANAGER:-unknown}"
        exit 1
    fi
}

atlas_package_update() {
    atlas_package_require_supported

    atlas_step "Updating apt package index"
    sudo apt-get update
}

atlas_package_is_installed() {
    local package_name="$1"

    atlas_package_require_supported

    dpkg -s "$package_name" >/dev/null 2>&1
}

atlas_package_install() {
    local package_name="$1"

    atlas_package_require_supported

    if atlas_package_is_installed "$package_name"; then
        atlas_success "$package_name already installed"
        return 0
    fi

    atlas_step "Installing $package_name"
    sudo apt-get install -y "$package_name"
    atlas_success "$package_name installed"
}
