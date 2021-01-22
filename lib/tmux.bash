tmux_get_option() {
  local option
  local default
  local value
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  echo "${value:-${default}}"
}

tmux_has_session() {
  local name
  name="$1"

  tmux has-session -t "=${name}" 1>/dev/null 2>&1
}

tmux_make_session_name() {
  local project_dir
  project_dir="$1"

  name="${project_dir##*/}"
  name="${name#\.}"
  name="${name//./_}"
  echo "$name"
}
