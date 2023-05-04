#!/usr/bin/env bash

basedir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/tmux.bash
. "${basedir}/lib/tmux.bash"

key="$(get_tmux_option '@project-key' 'g')"
if [[ -n "$key" ]]; then
	tmux bind-key "$key" run-shell -b "${basedir}/libexec/switch-project.bash"
fi
