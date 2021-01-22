# shellcheck disable=SC2034
default_workspace_dirs="${HOME}/develop/workspace"
tmux_option_workspace_dirs='@per-project-session-workspace-dirs'

default_workspace_maxdepth=2
tmux_option_workspace_maxdepth='@per-project-session-workspace-maxdepth'

default_known_project_dirs=''
tmux_option_known_project_dirs='@per-project-session-known-project-dirs'

default_fzf_opts='-d 15'
tmux_option_fzf_opts='@per-project-session-fzf-opts'

command_exists() {
  local command="$1"
  hash "$command" 2>/dev/null
}

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
        if [[ "$filepath" == ${HOME}* ]]; then
            filepath="${filepath/${HOME}/~}"
        fi

        echo "$filepath"
    done
}

filepath_expand() {
    local filepath="$1"

    if [[ "$filepath" == ~* ]]; then
        filepath="${filepath/~/${HOME}}"
    fi

    echo "$filepath"
}

filepath_to_tmux_session_name() {
    local filepath="$1"

    session_name="${filepath##*/}"
    session_name="${session_name#\.}"
    session_name="${session_name//./_}"
    echo "$session_name"
}
