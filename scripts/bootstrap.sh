#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_TOTAL=5
BOOTSTRAP_STARTED_AT=$SECONDS

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

run_stage 1 "$STAGE_TOTAL" \
    "Install Packages" \
    "$SCRIPT_DIR/install-packages.sh"

run_stage 2 "$STAGE_TOTAL" \
    "Configure Shell" \
    "$SCRIPT_DIR/configure-shell.sh"

run_stage 3 "$STAGE_TOTAL" \
    "Configure SSH" \
    "$SCRIPT_DIR/configure-ssh.sh"

run_stage 4 "$STAGE_TOTAL" \
    "Configure Tailscale" \
    "$SCRIPT_DIR/configure-tailscale.sh"

run_stage 5 "$STAGE_TOTAL" \
    "Install Atlas" \
    "$SCRIPT_DIR/install-atlas.sh"

BOOTSTRAP_ELAPSED=$((SECONDS - BOOTSTRAP_STARTED_AT))

atlas_section "Bootstrap Summary"
atlas_success "Install Packages"
atlas_success "Configure Shell"
atlas_success "Configure SSH"
atlas_success "Configure Tailscale"
atlas_success "Install Atlas"
echo
atlas_info "Elapsed time: $(atlas_format_duration "$BOOTSTRAP_ELAPSED")"

atlas_footer "Atlas Bootstrap completed successfully."
