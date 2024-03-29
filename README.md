# tmux-project

Search projects and open them in a new session.

## Prequisites

- find
- [fzf](https://github.com/junegunn/fzf) (needs `fzf-tmux` to be installed)

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the following line to your `.tmux.conf`.

```tmux
set -g @plugin 'sei40kr/tmux-project'
```

---

It is also recommended to add the following line to your `.tmux.conf` to prevent
a client from being detached when the active session is destroyed.

```tmux
set detach-on-destroy no-detached
```

## Customization

| Variable                        | Default value         | Description                                                                       |
| :------------------------------ | :-------------------- | :-------------------------------------------------------------------------------- |
| `@project-key`                  | `"g"`                 | The key to invoke the project search. If you set it to `""`, the key is disabled. |
| `@project-base-dirs`            | `""`                  | A comma-separated list of directories and their depths to search for projects.    |
| `@project-rooters`              | `".git"`              | A comma-separated list of rooters.                                                |
| `@project-fzf-tmux-layout-opts` | `""`                  | The layout options for fzf-tmux. See `fzf-tmux(1)` for details.                   |
| `@project-fzf-opts`             | `"--preview 'ls {}'"` | The options for fzf. See `fzf(1)` for details.                                    |

### Setting `@project-base-dirs`

`@project-base-dirs` is a comma-separated list of directories and their depths to search for projects.

Each element of the list is in the following format:

```
/path/to/dir[:<min depth>[:<max depth>]]
```

- If you omit `<min depth>` and `<max depth>`, they are set to `0` and `0` respectively.
- If you omit `<max depth>`, it is set to `<min depth>`. (means `<min depth>` is the exact depth)

If you omit the depth or explicitly set it to `0`, the directory itself will be
added as a project. In that case, you can add the directory as a project even if
it contains no rooter.

---

For example, if you want to search for ghq repositories as projects:

```tmux
set -ag @project-base-dirs ,"${GHQ_ROOT}:3"
```

For example, if you want to add `~/.vim` itself as a project:

```tmux
set -ag @project-base-dirs ,"${HOME}/.vim"
```

## tmuxinator Integration

tmux-project can be integrated with [tmuxinator](https://github.com/tmuxinator/tmuxinator).
When you have tmuxinator installed and the selected project has
`.tmuxinator.yml` at the root, tmux-project will start a new session with
tmuxinator.

## License

MIT
