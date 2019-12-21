#!/usr/bin/env bash
# -*- mode: sh -*-

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "${CURRENT_DIR}/scripts/helpers.bash"

default_key_bindings_goto='g'
tmux_option_goto='@per-project-session-goto'

set_goto_binding() {
    local key="$(get_tmux_option "$tmux_option_goto" \
                                 "$default_key_bindings_goto")"

    tmux bind-key "$key" run-shell -b "${CURRENT_DIR}/scripts/goto-session.bash"
}

main() {
    set_goto_binding
}

main
