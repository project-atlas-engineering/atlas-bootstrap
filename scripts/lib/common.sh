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

atlas_format_duration() {
    local total_seconds="$1"
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))

    if ((total_seconds == 0)); then
        printf "<1s"
    elif ((minutes > 0)); then
        printf "%dm %02ds" "$minutes" "$seconds"
    else
        printf "%ds" "$seconds"
    fi
}

run_stage() {
    local stage_number="$1"
    local stage_total="$2"
    local stage_name="$3"
    local script_path="$4"
    local started_at
    local elapsed
    local status

    atlas_section "[$stage_number/$stage_total] $stage_name"

    started_at=$SECONDS

    if "$script_path"; then
        status=0
    else
        status=$?
    fi

    elapsed=$((SECONDS - started_at))

    echo

    if ((status == 0)); then
        atlas_success "$stage_name complete ($(atlas_format_duration "$elapsed"))"
    else
        atlas_error "$stage_name failed with status $status ($(atlas_format_duration "$elapsed"))"
    fi

    return "$status"
}
