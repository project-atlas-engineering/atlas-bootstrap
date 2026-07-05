#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

atlas_header

atlas_section "Bootstrap Framework"
atlas_success "Framework initialized"

atlas_info "Host: $(hostname)"
atlas_info "Kernel: $(uname -sr)"
atlas_info "Architecture: $(uname -m)"
atlas_info "User: $(whoami)"

run_stage "Install Packages" "$SCRIPT_DIR/install-packages.sh"
run_stage "Configure Shell" "$SCRIPT_DIR/configure-shell.sh"
run_stage "Configure SSH" "$SCRIPT_DIR/configure-ssh.sh"
run_stage "Configure Tailscale" "$SCRIPT_DIR/configure-tailscale.sh"
run_stage "Install Atlas" "$SCRIPT_DIR/install-atlas.sh"

atlas_footer "Bootstrap completed successfully."
