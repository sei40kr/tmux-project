#!/usr/bin/env bash
# -*- mode: sh; sh-shell: bash -*-

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

default_key_binding_goto="g"
tmux_option_goto="@per-project-session-goto"

# shellcheck source=scripts/helpers.sh
. "${CURRENT_DIR}/scripts/helpers.sh"

set_goto_session_binding() {
    local key
    key="$(get_tmux_option "$tmux_option_goto" "$default_key_binding_goto")"

    tmux bind-key "$key" run-shell -b "${CURRENT_DIR}/scripts/goto_session.sh"
}

main() {
    set_goto_session_binding
}

main
