get_tmux_option() {
    local option="$1"
    local default_value="$2"
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

shorten_paths() {
    while read -r line; do
        if [[ "$line" == "$HOME"* ]]; then
            echo "~${line:${#HOME}}"
        else
            echo "$line"
        fi
    done
}

abbreviate_path() {
    local arg="$1"

    if [[ "$arg" == '~'* ]]; then
        echo "${HOME}${arg:1}"
    else
        echo "$arg"
    fi
}

project_dir_to_session_name() {
    local project_dir="$1"

    basename "$project_dir" | sed 's/^\.//;s/\./_/g'
}
