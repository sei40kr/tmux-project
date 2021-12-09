#!/usr/bin/env bash

: ${FZF_TMUX_GHQ_OPTS:="--prompt 'Switch to project: '"}

home_to_tilde() {
  while read -r path; do
    if [[ "$path" == "${HOME}"* ]]; then
      echo "${path/${HOME}/\~}"
    fi
  done
}

tilde_to_home() {
  local path
  read -r path

  if [[ "$path" == '~' || "$path" == '~/'* ]]; then
    echo "${path/\~/${HOME}}"
  fi
}

to_session_name() {
  local directory
  directory="$1"
  local session_name

  session_name="$directory"
  session_name="${session_name##*/}"
  session_name="${session_name//+([^0-9a-zA-Z])/_}"
  echo "$session_name"
}

project_directory="$(ghq list --full-path |
  home_to_tilde |
  eval "fzf-tmux ${FZF_TMUX_OPTS} ${FZF_TMUX_GHQ_OPTS}" |
  tilde_to_home)"

if [[ -z "$project_directory" ]]; then
  exit
fi

session_name="$(to_session_name "$project_directory")"

if ! tmux has-session -t "=${session_name}" 1>/dev/null 2>&1; then
  tmux new-session -dc "$project_directory" -s "$session_name" \; \
    set-option -t "$session_name" destroy-unattached off
fi

tmux switch-client -t "$session_name"
