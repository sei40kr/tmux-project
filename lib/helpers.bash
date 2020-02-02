# shellcheck disable=SC2034
default_workspace_dirs="${HOME}/develop/workspace"
tmux_option_workspace_dirs='@per-project-session-workspace-dirs'

default_workspace_maxdepth=2
tmux_option_workspace_maxdepth='@per-project-session-workspace-maxdepth'

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

tmux_get_option() {
    local option="$1"
    local default_value="$2"
    # shellcheck disable=2155
    local option_value="$(tmux show-option -gqv "$option")"

    if [[ -z "$option_value" ]]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

tmux_validate_options() {
    # shellcheck disable=SC2155
    local open_terminal_for_new_session="$(tmux_get_option "$tmux_option_open_terminal_for_new_session" \
        "$default_open_terminal_for_new_session")"
    if [[ "$open_terminal_for_new_session" != on ]]; then
        return
    fi

    # shellcheck disable=SC2155
    local set_titles="$(tmux_get_option set-titles off)"
    if [[ "$set_titles" != on ]]; then
        tmux display-message 'Error: You must set set-titles to on if you want to open a terminal for each new session.'
        return 1
    fi

    # shellcheck disable=SC2155
    local set_titles_string="$(tmux_get_option set-titles-string '')"
    if [[ ! "$set_titles_string" == *'#S'* ]]; then
        tmux display-message "Error: You must include #S in set-titles-string if you want to open a terminal for each new session."
        return 1
    fi

    # shellcheck disable=SC2155
    local terminal_cmd="$(tmux_get_option "$tmux_option_terminal_cmd" \
        "$default_terminal_cmd")"
    if [[ -z "$terminal_cmd" ]]; then
        tmux display-message "Error: You must set ${tmux_option_terminal_cmd} if you want to open a terminal for each new session."
        return 1
    fi
}

tmux_session_exists() {
    local session_name="$1"

    tmux has-session -t "=${session_name}" >/dev/null 2>&1
}


filepaths_stdin_dirname() {
    while read -r filepath; do
        echo "${filepath%%/.*}"
    done
}

filepaths_stdin_abbreviate() {
    while read -r filepath; do
        if [[ "${filepath:0:${#HOME}}" == "$HOME" ]]; then
            echo "~${filepath:${#HOME}}"
        else
            echo "$filepath"
        fi
    done
}

filepath_expand() {
    local filepath="$1"

    if [[ "${filepath:0:1}" == '~' ]]; then
        echo "${HOME}${filepath:1}"
    else
        echo "$filepath"
    fi
}

filepath_to_tmux_session_name() {
    local filepath="$1"

    session_name="${filepath##*/}"
    session_name="${session_name#\.}"
    session_name="${session_name//./_}"
    echo "$session_name"
}
