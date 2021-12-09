#!/usr/bin/env bash
# -*- mode: sh; sh-shell: bash -*-

basepath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux_get_option() {
  local name
  local default_value
  local value
  name="$1"
  default_value="$2"

  value="$(tmux show-option -gqv "$name")"
  echo "${value:-${default_value}}"
}

key="$(tmux_get_option '@ghq-create-or-switch-to' 'g')"
tmux bind-key "$key" run-shell -b "${basepath}/libexec/create-or-switch-to.bash"
