#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

TAILSCALE_SERVICE="tailscaled"

if ! sudo -v; then
    atlas_error "Administrative privileges are required to configure Tailscale"
    exit 1
fi

if ! command -v tailscale >/dev/null 2>&1; then
    atlas_error "Tailscale is not installed"
    atlas_info "Run the Install Tailscale stage first."
    exit 1
fi

atlas_success "Tailscale is installed"

if systemctl is-enabled --quiet "$TAILSCALE_SERVICE"; then
    atlas_success "Tailscale service already enabled"
else
    atlas_step "Enabling Tailscale service"
    sudo -n systemctl enable "$TAILSCALE_SERVICE"
    atlas_success "Tailscale service enabled"
fi

if systemctl is-active --quiet "$TAILSCALE_SERVICE"; then
    atlas_success "Tailscale service already active"
else
    atlas_step "Starting Tailscale service"
    sudo -n systemctl start "$TAILSCALE_SERVICE"
    atlas_success "Tailscale service started"
fi

tailscale_status="$(tailscale status --json 2>/dev/null || true)"
backend_state=""

if [[ -n "$tailscale_status" ]]; then
    backend_state="$(jq -r '.BackendState // empty' <<< "$tailscale_status")"
fi

case "$backend_state" in
    Running)
        tailscale_ipv4="$(tailscale ip -4 2>/dev/null || true)"

        atlas_success "Tailscale is connected"

        if [[ -n "$tailscale_ipv4" ]]; then
            atlas_info "Tailscale IPv4: $tailscale_ipv4"
        fi
        ;;

	NeedsLogin)
	    echo
	    echo "------------------------------------------------------------"
	    echo "Manual action required"
	    echo
	    echo "Tailscale has been installed and the service is running,"
	    echo "but this machine has not yet been authenticated."
	    echo
	    echo "Open another terminal and run:"
	    echo
	    echo "    sudo tailscale up"
	    echo
	    echo "Complete the authentication in your browser."
	    echo
	    echo "When finished, return to this window and press ENTER."
	    echo
	    echo "Press Ctrl+C at any time to cancel Bootstrap."
	    echo
	    echo "Atlas Bootstrap is fully resumable. You can safely rerun it"
	    echo "later—it will detect completed work and avoid reinstalling"
	    echo "or reconfiguring components unnecessarily."
	    echo "------------------------------------------------------------"

	    while true; do
	        read -rp "Press ENTER after Tailscale authentication..."

	        tailscale_status="$(tailscale status --json 2>/dev/null || true)"
	        backend_state="$(jq -r '.BackendState // empty' <<<"$tailscale_status")"

	        if [[ "$backend_state" == "Running" ]]; then
	            tailscale_ipv4="$(tailscale ip -4 2>/dev/null || true)"

	            atlas_success "Tailscale authenticated"

	            if [[ -n "$tailscale_ipv4" ]]; then
	                atlas_info "Tailscale IPv4: $tailscale_ipv4"
	            fi

	            break
	        fi

	        atlas_info "Tailscale is not connected yet."
	        atlas_info "Run 'sudo tailscale up' in another terminal, then return here."
	    done
	    ;;

    Stopped)
        atlas_info "Tailscale is installed but stopped"
        atlas_info "Run: sudo tailscale up"
        exit 1
        ;;

    *)
        atlas_error "Unable to determine Tailscale connection state"

        if [[ -n "$backend_state" ]]; then
            atlas_info "Backend state: $backend_state"
        fi

        exit 1
        ;;
esac

atlas_success "Tailscale configuration complete"
