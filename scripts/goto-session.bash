#!/usr/bin/env bash

# goto-session.bash
# author: Seong Yong-ju <sei40kr@gmail.com>

set -uo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "${CURRENT_DIR}/helpers.bash"

default_workspace_dirs="${HOME}/develop/workspace"
tmux_option_workspace_dirs='@per-project-session-workspace-dirs'

default_workspace_max_depth=2
tmux_option_workspace_max_depth='@per-project-session-workspace-max-depth'

default_known_project_dirs=''
tmux_option_known_project_dirs='@per-project-session-known-project-dirs'

default_fzf_opts='-d 15'
tmux_option_fzf_opts='@per-project-session-fzf-opts'

default_destroy_unnamed=on
tmux_option_destroy_unnamed='@per-project-session-destroy-unnamed'

abbreviate_stdin_dir() {
    read -r dir
    abbreviate_dir "$dir"
}

list_project_dirs() {
    local known_project_dirs
    IFS=':' read -a known_project_dirs \
       < <(get_tmux_option "$tmux_option_known_project_dirs" \
                           "$default_known_project_dirs")

    for project_dir in "${known_project_dirs[@]}"; do
        if [[ -n "$project_dir" && -d "$project_dir" ]]; then
            echo "$project_dir"
        fi
    done

    local workspace_dirs
    local max_depth="$(get_tmux_option "$tmux_option_workspace_max_depth" \
                                       "$default_workspace_max_depth")"
    IFS=':' read -a workspace_dirs \
       < <(get_tmux_option "$tmux_option_workspace_dirs" \
                           "$default_workspace_dirs")

    for workspace_dir in "${workspace_dirs[@]}"; do
        if [[ -n "$workspace_dir" ]]; then
            find -L "$workspace_dir" \
                 -maxdepth "$(($max_depth+1))" \
                 -type d \
                 -name '.git' \
                 -exec dirname {} +
        fi
    done
}

main() {
    local fzf_opts="$(get_tmux_option "$tmux_option_fzf_opts" \
                                      "$default_fzf_opts")"
    local destroy_unnamed="$(get_tmux_option "$tmux_option_destroy_unnamed" \
                                             "$default_destroy_unnamed")"
    local project_dir
    local session_name

    project_dir="$(list_project_dirs |
                       shorten_paths |
                       eval "fzf-tmux ${fzf_opts}")"

    if [[ -z "$project_dir" ]]; then
        return
    fi

    project_dir="$(abbreviate_path "$project_dir")"
    session_name="$(project_dir_to_session_name "$project_dir")"

    if ! tmux_session_exists "$session_name"; then
        tmux new-session -dc "$project_dir" -s "$session_name"
    fi

    if [[ "$destroy_unnamed" == on ]]; then
        local prev_session_name="$(tmux display-message -p '#S')"
    fi

    tmux switch-client -t "$session_name"

    if [[ "$destroy_unnamed" == on && "$prev_session_name" =~ '^[0-9]$' ]]; then
        tmux kill-session "$prev_session_name"
    fi
}

main
