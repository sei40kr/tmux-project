#!/usr/bin/env bash
# -*- mode: sh; sh-shell: bash -*-

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

default_key_binding_switch="g"
tmux_option_switch="@per-project-session-switch"

# shellcheck source=scripts/helpers.sh
. "${CURRENT_DIR}/scripts/helpers.sh"

set_new_session_binding() {
    local key
    key="$(get_tmux_option "$tmux_option_switch" "$default_key_binding_switch")"

    tmux bind-key "$key" run-shell -b "${CURRENT_DIR}/scripts/switch_session.sh"
}

main() {
    set_new_session_binding
}

main
