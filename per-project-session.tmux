#!/usr/bin/env bash
# -*- mode: sh -*-

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/helpers.bash
. "${basedir}/lib/helpers.bash"

default_key_bindings_goto='g'
tmux_option_goto='@per-project-session-goto'

set_key_bindings() {
    # shellcheck disable=SC2155
    local key_goto="$(tmux_get_option "$tmux_option_goto" \
        "$default_key_bindings_goto")"
    tmux bind-key "$key_goto" run-shell -b \
        "${basedir}/libexec/goto-session.bash"
}

main() {
    set_key_bindings
}

main
