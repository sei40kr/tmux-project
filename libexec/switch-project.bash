#!/usr/bin/env bash

basedir="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/tmux.bash
. "$basedir/lib/tmux.bash"

find_projects() {
	local -a base_dirs rooters rooter_opts

	IFS=',' read -ra base_dirs < <(get_tmux_option '@project-base-dirs')
	IFS=',' read -ra rooters < <(get_tmux_option '@project-rooters' '.git')

	for rooter in "${rooters[@]}"; do
		rooter_opts+=("-o" "-name" "$rooter")
	done
	rooter_opts=('(' "${rooter_opts[@]:1}" ')')

	for base_dir in "${base_dirs[@]}"; do
		# If the base_dir is empty, skip it
		if [[ -z "$base_dir" ]]; then
			continue
		fi

		local -a tmp
		IFS=':' read -ra tmp <<<"$base_dir"
		path="${tmp[0]}"
		min_depth="${tmp[1]:-0}"
		max_depth="${tmp[2]:-${min_depth}}"

		find "$path" -mindepth "$((min_depth + 1))" \
			-maxdepth "$((max_depth + 1))" \
			"${rooter_opts[@]}" \
			-printf '%h\n'
	done
}

# Convert a path to a session name. The session name is the last component of
# the path. Dots are replaced with underscores. If the path starts with a dot,
# the dot is removed.
# e.g. /home/username/.emacs.d -> emacs_d
to_session_name() {
	local session_name="$1"

	session_name="${session_name##*/}"

	# Dots are not allowed in a tmux session name
	# e.g. .emacs.d -> _emacs_d
	session_name="${session_name//./_}"
	# If the path starts with a slash (a dot), remove it
	# e.g. .emacs.d -> _emacs_d -> emacs_d
	session_name="${session_name#_}"

	echo "$session_name"
}

main() {
	local fzf_opts fzf_tmux_layout_opts selected_path session_name

	# shellcheck disable=SC2207
	fzf_opts="$(get_tmux_option "@project-fzf-opts" "--preview 'ls {}'")"
	# shellcheck disable=SC2207
	fzf_tmux_layout_opts="$(get_tmux_option "@project-fzf-tmux-layout-opts")"

	selected_path="$(find_projects | eval "fzf-tmux ${fzf_tmux_layout_opts} -- ${fzf_opts}")"
	if [[ -z "$selected_path" ]]; then
		return 0
	fi

	session_name="$(to_session_name "$selected_path")"

	# If the session already exists, attach to it. Otherwise, create a new
	# session and attach to it.
	if ! tmux has-session -t "$session_name" 2>/dev/null; then
		# Return 0 even if creating the session fails.
		tmux new-session -d -s "$session_name" -c "$selected_path" || :
	fi
	tmux switch-client -t "$session_name"
}

main "$@"
