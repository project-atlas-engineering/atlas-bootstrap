#!/usr/bin/env bash

# Package management helpers for Atlas Bootstrap.

atlas_package_require_supported() {
    if [[ "${ATLAS_PACKAGE_MANAGER:-unknown}" != "apt" ]]; then
        atlas_error "Unsupported package manager: ${ATLAS_PACKAGE_MANAGER:-unknown}"
        exit 1
    fi
}

atlas_package_run_privileged() {
    if [[ "${ATLAS_IS_ROOT:-false}" == true ]]; then
        "$@"
    elif [[ "${ATLAS_HAS_SUDO:-false}" == true ]]; then
        sudo "$@"
    else
        atlas_error "Package management requires root privileges or sudo."
        exit 1
    fi
}

atlas_package_update() {
    atlas_package_require_supported

    atlas_step "Updating apt package index"
    atlas_package_run_privileged apt-get update
}

atlas_package_is_installed() {
    local package_name="$1"

    atlas_package_require_supported

    dpkg-query \
        --show \
        --showformat='${db:Status-Abbrev}' \
        "$package_name" 2>/dev/null |
        grep -q '^ii '
}

atlas_package_install() {
    local packages=("$@")

    atlas_package_require_supported

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi

    atlas_step "Installing ${#packages[@]} package(s)"
    atlas_package_run_privileged apt-get install -y "${packages[@]}"
}
