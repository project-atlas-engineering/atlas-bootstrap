#!/usr/bin/env bash

# Shared framework helpers for Atlas Bootstrap.

if [[ -t 1 ]]; then
    ATLAS_RESET="\033[0m"
    ATLAS_BOLD="\033[1m"
    ATLAS_DIM="\033[2m"
    ATLAS_GREEN="\033[32m"
    ATLAS_YELLOW="\033[33m"
    ATLAS_RED="\033[31m"
    ATLAS_BLUE="\033[34m"
else
    ATLAS_RESET=""
    ATLAS_BOLD=""
    ATLAS_DIM=""
    ATLAS_GREEN=""
    ATLAS_YELLOW=""
    ATLAS_RED=""
    ATLAS_BLUE=""
fi

atlas_header() {
    echo
    echo "============================================================"
    echo "                  Project Atlas Bootstrap"
    echo "============================================================"
    echo
}

atlas_footer() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

atlas_section() {
    echo
    echo -e "${ATLAS_BOLD}$1${ATLAS_RESET}"
    echo "------------------------------------------------------------"
}

atlas_step() {
    echo -e "${ATLAS_BLUE}→${ATLAS_RESET} $1"
}

atlas_info() {
    echo -e "  ${ATLAS_DIM}$1${ATLAS_RESET}"
}

atlas_success() {
    echo -e "${ATLAS_GREEN}✓${ATLAS_RESET} $1"
}

atlas_warn() {
    echo -e "${ATLAS_YELLOW}!${ATLAS_RESET} $1"
}

atlas_error() {
    echo -e "${ATLAS_RED}✗${ATLAS_RESET} $1" >&2
}

atlas_progress() {
    local label="$1"
    local width=28
    local delay=0.025

    printf "  %s [" "$label"

    for ((i = 0; i < width; i++)); do
        printf "#"
        sleep "$delay"
    done

    printf "] done\n"
}

run_stage() {
    local stage_name="$1"
    local script_path="$2"

    atlas_section "$stage_name"
    atlas_step "Delegating to $(basename "$script_path")"
    atlas_progress "Running"

    "$script_path"

    atlas_success "Complete"
}
