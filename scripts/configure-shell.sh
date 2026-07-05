#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

ATLAS_CONFIG_DIR="$HOME/.config/atlas"
USER_ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source "$HOME/.config/atlas/zshrc"'

mkdir -p "$ATLAS_CONFIG_DIR"

cp "$REPO_ROOT/templates/shell/zshrc" "$ATLAS_CONFIG_DIR/zshrc"
cp "$REPO_ROOT/templates/shell/environment" "$ATLAS_CONFIG_DIR/environment"
cp "$REPO_ROOT/templates/shell/aliases" "$ATLAS_CONFIG_DIR/aliases"

atlas_success "Installed Atlas shell configuration"

if [[ ! -f "$USER_ZSHRC" ]]; then
    touch "$USER_ZSHRC"
fi

if grep -Fq "$SOURCE_LINE" "$USER_ZSHRC"; then
    atlas_success "Atlas shell configuration already sourced"
else
    {
        echo
        echo "# Atlas Bootstrap"
        echo "$SOURCE_LINE"
    } >> "$USER_ZSHRC"

    atlas_success "Added Atlas shell source line to ~/.zshrc"
fi
