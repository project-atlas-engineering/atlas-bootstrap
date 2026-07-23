#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_STARTED_AT=$SECONDS

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system.sh"

STAGE_NAMES=(
    "Install Packages"
    "Configure Shell"
    "Configure SSH"
    "Configure Tailscale"
    "Install Atlas"
)

STAGE_SCRIPTS=(
    "$SCRIPT_DIR/install-packages.sh"
    "$SCRIPT_DIR/configure-shell.sh"
    "$SCRIPT_DIR/configure-ssh.sh"
    "$SCRIPT_DIR/configure-tailscale.sh"
    "$SCRIPT_DIR/install-atlas.sh"
)

STAGE_STATUSES=(
    "pending"
    "pending"
    "pending"
    "pending"
    "pending"
)

STAGE_TOTAL="${#STAGE_NAMES[@]}"
BOOTSTRAP_STATUS=0

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

for index in "${!STAGE_NAMES[@]}"; do
    stage_number=$((index + 1))

    if run_stage \
        "$stage_number" \
        "$STAGE_TOTAL" \
        "${STAGE_NAMES[$index]}" \
        "${STAGE_SCRIPTS[$index]}"
    then
        STAGE_STATUSES[$index]="complete"
    else
        STAGE_STATUSES[$index]="failed"
        BOOTSTRAP_STATUS=1
        break
    fi
done

BOOTSTRAP_ELAPSED=$((SECONDS - BOOTSTRAP_STARTED_AT))

atlas_section "Bootstrap Summary"

for index in "${!STAGE_NAMES[@]}"; do
    case "${STAGE_STATUSES[$index]}" in
        complete)
            atlas_success "${STAGE_NAMES[$index]}"
            ;;
        failed)
            atlas_error "${STAGE_NAMES[$index]}"
            ;;
        pending)
            atlas_warn "${STAGE_NAMES[$index]} — not run"
            ;;
    esac
done

echo
atlas_info "Elapsed time: $(atlas_format_duration "$BOOTSTRAP_ELAPSED")"

if ((BOOTSTRAP_STATUS == 0)); then
    atlas_footer "Atlas Bootstrap completed successfully."
else
    atlas_footer "Atlas Bootstrap did not complete."
fi

exit "$BOOTSTRAP_STATUS"
