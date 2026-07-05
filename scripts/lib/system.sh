#!/usr/bin/env bash

# System detection helpers for Atlas Bootstrap.

atlas_detect_system() {
    ATLAS_HOSTNAME="$(hostname)"
    ATLAS_KERNEL="$(uname -sr)"
    ATLAS_ARCH="$(uname -m)"

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release

        ATLAS_DISTRO="${NAME:-Unknown}"
        ATLAS_VERSION="${VERSION_ID:-Unknown}"
    else
        ATLAS_DISTRO="Unknown"
        ATLAS_VERSION="Unknown"
    fi

    if command -v apt-get >/dev/null 2>&1; then
        ATLAS_PACKAGE_MANAGER="apt"
        ATLAS_PLATFORM="debian"
    else
        ATLAS_PACKAGE_MANAGER="unknown"
        ATLAS_PLATFORM="unknown"
    fi

    if [[ $EUID -eq 0 ]]; then
        ATLAS_IS_ROOT=true
    else
        ATLAS_IS_ROOT=false
    fi

    if command -v sudo >/dev/null 2>&1; then
        ATLAS_HAS_SUDO=true
    else
        ATLAS_HAS_SUDO=false
    fi
}
