#!/usr/bin/env bash

# goto-session.bash
# author: Seong Yong-ju <sei40kr@gmail.com>

set -uo pipefail

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/helpers.bash
. "${basedir}/lib/helpers.bash"

list_project_dirs() {
    local known_project_dirs
    IFS=':' read -r -a known_project_dirs \
        < <(tmux_get_option "$tmux_option_known_project_dirs" \
        "$default_known_project_dirs")
    for project_dir in "${known_project_dirs[@]}"; do
        if [[ -n "$project_dir" && -d "$project_dir" ]]; then
            echo "$project_dir"
        fi
    done

    local workspace_dirs
    # shellcheck disable=SC2155
    local maxdepth="$(tmux_get_option "$tmux_option_workspace_maxdepth" \
        "$default_workspace_maxdepth")"
    IFS=':' read -r -a workspace_dirs \
        < <(tmux_get_option "$tmux_option_workspace_dirs" \
        "$default_workspace_dirs")
    {
        for workspace_dir in "${workspace_dirs[@]}"; do
            if [[ -n "$workspace_dir" && -d "$workspace_dir" ]]; then
                if command_exists fd; then
                    fd -H -L -d "$((maxdepth+1))" -t d '^\.git$' "$workspace_dir"
                else
                    find -L "$workspace_dir" \
                        -maxdepth "$((maxdepth+1))" \
                        -type d \
                        -name '.git'
                fi
            fi
        done
    } | filepaths_stdin_dirname
}

main() {
    # shellcheck disable=SC2155
    local fzf_opts="$(tmux_get_option "$tmux_option_fzf_opts" \
        "$default_fzf_opts")"
    # shellcheck disable=SC2155
    local project_dir="$(list_project_dirs |
                             filepaths_stdin_abbreviate |
                             eval "fzf-tmux ${fzf_opts}")"
    if [[ -z "$project_dir" ]]; then
        return
    fi
    project_dir="$(filepath_expand "$project_dir")"

    # shellcheck disable=SC2155
    local new_session="$(filepath_to_tmux_session_name "$project_dir")"
    if ! tmux_session_exists "$new_session"; then
        tmux new-session -d -c "$project_dir" -s "$new_session"
    fi

    tmux switch-client -t "$new_session"
}

main
