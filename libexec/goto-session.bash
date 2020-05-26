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
    for workspace_dir in "${workspace_dirs[@]}"; do
        if [[ -n "$workspace_dir" && -d "$workspace_dir" ]]; then
            {
                if command_exists fd; then
                    fd -H -L -d "$((maxdepth+1))" -t d '^\.git$' "$workspace_dir"
                else
                    find -L "$workspace_dir" \
                        -maxdepth "$((maxdepth+1))" \
                        -type d \
                        -name '.git'
                fi
            } | filepaths_stdin_dirname
        fi
    done
}

main() {
    tmux_validate_options || exit "$?"

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
    local destroy_unnamed="$(tmux_get_option "$tmux_option_destroy_unnamed" \
        "$default_destroy_unnamed")"
    local session_to_destroy
    if [[ "$destroy_unnamed" == on ]]; then
        # shellcheck disable=SC2155
        local prev_session="$(tmux display-message -p '#S')"
        if [[ "$prev_session" =~ ^[[:digit:]]+$ ]]; then
            session_to_destroy="$prev_session"
        fi
    fi

    # shellcheck disable=SC2155
    local new_session="$(filepath_to_tmux_session_name "$project_dir")"
    if ! tmux_session_exists "$new_session"; then
        tmux new-session -d -c "$project_dir" -s "$new_session"
    fi

    # shellcheck disable=SC2155
    local open_terminal_for_new_session="$(tmux_get_option \
        "$tmux_option_open_terminal_for_new_session" \
        "$default_open_terminal_for_new_session")"
    # shellcheck disable=SC2155
    local set_titles_string="$(tmux_get_option 'set-titles-string' '')"
    if [[ "$open_terminal_for_new_session" == on ]]; then
        local terminal_title="${set_titles_string//#S/${new_session}}"

        # shellcheck disable=SC2155
        local terminal_cmd="$(tmux_get_option "$tmux_option_terminal_cmd" \
            "$default_terminal_cmd")"
        if ! wmctrl -F -a "$terminal_title"; then
            eval "$(printf "${terminal_cmd} ${SHELL} -c %q" \
                "$(printf 'tmux attach-session -t %q' "$new_session")")" &
            disown -h "$!"
        fi
    else
        tmux switch-client -t "$new_session"
    fi

    if [[ "$destroy_unnamed" == on && -n "$session_to_destroy" ]]; then
        if [[ "$open_terminal_for_new_session" == on ]]; then
            tmux set-option detach-on-destroy on
        fi

        tmux kill-session -t "$session_to_destroy"
    fi
}

main
