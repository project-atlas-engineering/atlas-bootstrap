#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system.sh"

atlas_detect_system

atlas_header

atlas_section "System Information"

atlas_info "Hostname:        $ATLAS_HOSTNAME"
atlas_info "Distribution:    $ATLAS_DISTRO $ATLAS_VERSION"
atlas_info "Kernel:          $ATLAS_KERNEL"
atlas_info "Architecture:    $ATLAS_ARCH"
atlas_info "Platform:        $ATLAS_PLATFORM"
atlas_info "Package Manager: $ATLAS_PACKAGE_MANAGER"

if [[ "$ATLAS_IS_ROOT" == true ]]; then
    atlas_info "Privileges:      root"
elif [[ "$ATLAS_HAS_SUDO" == true ]]; then
    atlas_info "Privileges:      sudo available"
else
    atlas_info "Privileges:      standard user"
fi

atlas_section "Bootstrap Framework"
atlas_success "Framework initialized"

run_stage "Install Packages" "$SCRIPT_DIR/install-packages.sh"
run_stage "Configure Shell" "$SCRIPT_DIR/configure-shell.sh"
run_stage "Configure SSH" "$SCRIPT_DIR/configure-ssh.sh"
run_stage "Configure Tailscale" "$SCRIPT_DIR/configure-tailscale.sh"
run_stage "Install Atlas" "$SCRIPT_DIR/install-atlas.sh"

atlas_footer "Bootstrap completed successfully."
