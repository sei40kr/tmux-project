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

default_open_terminal_for_new_session=off
tmux_option_open_terminal_for_new_session='@per-project-session-open-terminal-for-new-session'

default_terminal_cmd=''
tmux_option_terminal_cmd='@per-project-session-terminal-cmd'

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

validate_tmux_title_options() {
    local set_titles="$1"
    local set_titles_string="$2"
    local terminal_cmd="$3"

    if [[ "$set_titles" != on ]]; then
        tmux display-message 'Error: You need to set set-titles to on if you want to open a terminal for new session.'
        return 1
    fi

    if [[ ! "$set_titles_string" =~ \#S ]]; then
        tmux display-message "Error: You need to include #S in set-titles-string if you want to open a terminal for new session."
        return 1
    fi

    if [[ -z "$terminal_cmd" ]]; then
        tmux display-message "Error: You need to set ${tmux_option_terminal_cmd} if you want to open a terminal for new session."
        return 1
    fi
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

    if [[ "$destroy_unnamed" == on ]]; then
        local prev_session_name="$(tmux display-message -p '#S')"
    fi

    project_dir="$(abbreviate_path "$project_dir")"
    session_name="$(project_dir_to_session_name "$project_dir")"

    local open_terminal_for_new_session="$(get_tmux_option "$tmux_option_open_terminal_for_new_session" \
                                                           "$default_open_terminal_for_new_session")"
    if [[ "$open_terminal_for_new_session" == on ]]; then
        local set_titles="$(get_tmux_option set-titles off)"
        local set_titles_string="$(get_tmux_option set-titles-string '')"
        local terminal_cmd="$(get_tmux_option "$tmux_option_terminal_cmd" "$default_terminal_cmd")"

        validate_tmux_title_options "$set_titles" \
                                    "$set_titles_string" \
                                    "$terminal_cmd" || exit "$?"
    fi

    if ! tmux_session_exists "$session_name"; then
        tmux new-session -dc "$project_dir" -s "$session_name"
    fi

    if [[ "$open_terminal_for_new_session" == on ]]; then
        local terminal_title="${set_titles_string//#S/${session_name}}"

        if ! wmctrl -F -a "$terminal_title"; then
            eval "$(printf "${terminal_cmd} ${SHELL} -c %q" \
                           "$(printf 'tmux attach-session -t %q' "$session_name")")" &
            disown -h "$!"
        fi
    else
        tmux switch-client -t "$session_name"
    fi

    if [[ "$destroy_unnamed" == on && "$prev_session_name" =~ ^[[:digit:]]+$ ]]; then
        if [[ "$open_terminal_for_new_session" == on ]]; then
            tmux set-option detach-on-destroy on
        fi

        tmux kill-session -t "$prev_session_name"
    fi
}

main
