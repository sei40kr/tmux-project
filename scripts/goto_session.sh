#!/usr/bin/env bash
# -*- mode: sh; sh-shell: bash -*-

set -uo pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

default_known_project_dirs=''
tmux_option_known_project_dirs='@per-project-session-known-project-dirs'

default_workspace_dirs="${HOME}/develop/workspace"
tmux_option_workspace_dirs='@per-project-session-workspace-dirs'

default_max_depth=2
tmux_option_max_depth='@per-project-session-workspace-max-depth'

default_fzf_tmux_options='-d 30%'
tmux_option_fzf_tmux_options='@per-project-session-fzf-tmux-options'

# shellcheck source=helpers.sh
. "${CURRENT_DIR}/helpers.sh"

executable() {
  local name
  name="$1"

  [[ -x "$name" ]] || hash "$name" 2>/dev/null
}

fast_dirname() {
  local string
  string="$1"

  echo "${string%%/.*}"
}

fast_dirname_stdin() {
  while read -r line; do
    fast_dirname "$line"
  done
}

abbrev_path() {
  local string
  string="$1"

  if [[ "$string" == "${HOME}"* ]]; then
    string="${string/${HOME}/\~}"
  fi

  echo "$string"
}

abbrev_path_stdin() {
  while read -r line; do
    abbrev_path "$line"
  done
}

expand_path() {
  local string
  string="$1"

  # shellcheck disable=SC2088
  if [[ "$string" == '~' || "$string" == '~/'* ]]; then
    string="${string/\~/${HOME}}"
  fi

  echo "$string"
}

find_projects() {
  local known_project_dirs
  local workspace_dirs
  local max_depth
  IFS=':' read -r -a workspace_dirs \
    < <(get_tmux_option "$tmux_option_workspace_dirs" "$default_workspace_dirs")
  IFS=':' read -ra known_project_dirs \
    < <(get_tmux_option "$tmux_option_known_project_dirs" "$default_known_project_dirs")
  max_depth="$(get_tmux_option "$tmux_option_max_depth" $default_max_depth)"

  {
    for project_dir in "${known_project_dirs[@]}"; do
      if [[ -n "$project_dir" && -d "$project_dir" ]]; then
        echo "$project_dir"
      fi
    done

    for workspace_dir in "${workspace_dirs[@]}"; do
      if [[ -n "$workspace_dir" && -d "$workspace_dir" ]]; then
        if executable fd; then
          fd -H -L \
            -d "$((max_depth + 1))" \
            -t d \
            '^\.git$' \
            "$workspace_dir"
        else
          find -L "$workspace_dir" \
            -maxdepth "$((max_depth + 1))" \
            -type d \
            -name '.git'
        fi
      fi
    done | fast_dirname_stdin
  } | abbrev_path_stdin

}

main() {
  local fzf_tmux_opts
  local project_dir
  local session_name
  fzf_tmux_opts="$(get_tmux_option "$tmux_option_fzf_tmux_options" "$default_fzf_tmux_options")"

  project_dir="$(find_projects |
    abbrev_path_stdin |
    eval "fzf-tmux ${fzf_tmux_opts}")"

  if [[ -z "$project_dir" ]]; then
    return
  fi

  project_dir="$(expand_path "$project_dir")"

  session_name="$(tmux_make_session_name "$project_dir")"

  if ! tmux_has_session "$session_name"; then
    tmux new-session -d -c "$project_dir" -s "$session_name"
  fi

  tmux switch-client -t "$session_name"
}

main
