#!/usr/bin/env bash
# -*- mode: sh -*-

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/tmux.bash
. "${basedir}/lib/tmux.bash"

main() {
    local switch_key
    switch_key="$(tmux_get_option "@per-project-session-switch" 'g')"

    tmux bind-key "$switch_key" run-shell -b "${basedir}/libexec/switch-session"
}

main
