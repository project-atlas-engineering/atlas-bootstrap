#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"
SSH_SERVICE="ssh"

if ! sudo -v; then
    atlas_error "Administrative privileges are required to configure SSH"
    exit 1
fi

if ! sudo -v; then
    atlas_error "Administrative privileges are required to configure SSH"
    exit 1
fi

if ! [[ -x /usr/sbin/sshd ]]; then
    atlas_error "OpenSSH server is not installed"
    exit 1
fi

atlas_success "OpenSSH server is installed"

if [[ -d "$SSH_DIR" ]]; then
    atlas_success "SSH directory already exists: ~/.ssh"
else
    mkdir -p "$SSH_DIR"
    atlas_success "Created SSH directory: ~/.ssh"
fi

chmod 700 "$SSH_DIR"
atlas_success "SSH directory permissions set to 700"

if systemctl is-enabled --quiet "$SSH_SERVICE"; then
    atlas_success "SSH service already enabled"
else
    atlas_step "Enabling SSH service"
    sudo systemctl enable "$SSH_SERVICE"
    atlas_success "SSH service enabled"
fi

if systemctl is-active --quiet "$SSH_SERVICE"; then
    atlas_success "SSH service already active"
else
    atlas_step "Starting SSH service"
    sudo systemctl start "$SSH_SERVICE"
    atlas_success "SSH service started"
fi

if sudo -n /usr/sbin/sshd -t; then
    atlas_success "SSH server configuration is valid"
else
    atlas_error "SSH server configuration validation failed"
    exit 1
fi

atlas_success "SSH configuration complete"
