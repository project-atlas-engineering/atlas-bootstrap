#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

TAILSCALE_KEYRING="/usr/share/keyrings/tailscale-archive-keyring.gpg"
TAILSCALE_REPOSITORY="/etc/apt/sources.list.d/tailscale.list"

if ! sudo -v; then
    atlas_error "Administrative privileges are required to install Tailscale"
    exit 1
fi

install_tailscale() {
    local distribution_id
    local distribution_codename
    local repository_base
    local temporary_directory
    local temporary_keyring
    local temporary_repository

    distribution_id="$(
        . /etc/os-release
        printf '%s\n' "${ID:-}"
    )"

    distribution_codename="$(
        . /etc/os-release
        printf '%s\n' "${VERSION_CODENAME:-}"
    )"

    if [[ "$distribution_id" != "debian" ]]; then
        atlas_error "Automatic Tailscale installation currently supports Debian only"
        atlas_info "Detected distribution: ${distribution_id:-unknown}"
        return 1
    fi

    if [[ -z "$distribution_codename" ]]; then
        atlas_error "Unable to determine the Debian release codename"
        return 1
    fi

    repository_base="https://pkgs.tailscale.com/stable/debian"
    temporary_directory="$(mktemp -d)"
    temporary_keyring="$temporary_directory/tailscale-archive-keyring.gpg"
    temporary_repository="$temporary_directory/tailscale.list"

    trap 'rm -rf "$temporary_directory"' RETURN

    atlas_step "Downloading Tailscale repository key"
    curl -fsSL \
        "$repository_base/$distribution_codename.noarmor.gpg" \
        -o "$temporary_keyring"

    atlas_step "Downloading Tailscale repository definition"
    curl -fsSL \
        "$repository_base/$distribution_codename.tailscale-keyring.list" \
        -o "$temporary_repository"

    sudo -n install -d -m 0755 /usr/share/keyrings
    sudo -n install -m 0644 "$temporary_keyring" "$TAILSCALE_KEYRING"
    sudo -n install -m 0644 "$temporary_repository" "$TAILSCALE_REPOSITORY"

    atlas_success "Tailscale repository configured"

    atlas_step "Updating package metadata"
    sudo -n apt-get update

    atlas_step "Installing Tailscale"
    sudo -n apt-get install -y tailscale

    atlas_success "Tailscale installed"
}

if command -v tailscale >/dev/null 2>&1; then
    atlas_success "Tailscale is already installed"
else
    atlas_info "Tailscale is not installed"
    install_tailscale
fi

atlas_success "Tailscale installation complete"
