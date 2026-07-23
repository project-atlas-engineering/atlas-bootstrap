#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

ATLAS_HOME="${ATLAS_HOME:-$HOME/atlas}"

ATLAS_DIRECTORIES=(
    "$ATLAS_HOME"
    "$ATLAS_HOME/bin"
    "$ATLAS_HOME/docs"
    "$ATLAS_HOME/repos"
    "$ATLAS_HOME/scripts"
    "$ATLAS_HOME/tmp"
)

created_count=0
existing_count=0

atlas_info "Atlas home: $ATLAS_HOME"
atlas_step "Provisioning Atlas directory structure"

for directory in "${ATLAS_DIRECTORIES[@]}"; do
    display_path="${directory/#$HOME/\~}"

    if [[ -d "$directory" ]]; then
        atlas_success "Already exists: $display_path"
        ((existing_count += 1))
        continue
    fi

    if [[ -e "$directory" ]]; then
        atlas_error "Cannot create directory because another filesystem object exists: $display_path"
        exit 1
    fi

    mkdir -p "$directory"
    atlas_success "Created: $display_path"
    ((created_count += 1))
done

echo
atlas_info "Directories requested: ${#ATLAS_DIRECTORIES[@]}"
atlas_info "Already existed:      $existing_count"
atlas_info "Created now:          $created_count"

atlas_success "Atlas directory provisioning complete"
