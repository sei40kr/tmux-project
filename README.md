# tmux-per-project-session

A project-orientated session manager for tmux.

## Requirements

- [fzf](https://github.com/junegunn/fzf) (with `fzf-tmux`)

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the plugin to the list of TPM plugins in your `.tmux.conf` like below:

```tmux
set -g @plugin 'sei40kr/tmux-per-project-session'
```

## Customization

| Variable                                   | Default Value               | Description                                                                                                                                                           |
| :--                                        | :--                         | :--                                                                                                                                                                   |
| `@per-project-session-goto`                | `g`                         | A key binding to switch a session. The default is `prefix + g`.                                                                                                       |
| `@per-project-session-workspace-dirs`      | `${HOME}/develop/workspace` | Workspace directories. You can specify multiple directories by separating them with `:`.                                                                              |
| `@per-project-session-workspace-max-depth` | `2`                         | The number of max levels below the workspace directories to search projects.                                                                                          |
| `@per-project-session-known-project-dirs`  | `''`                        | Project directories outside the workspace directories. For example, you can put `~/.dotfiles` here. You can specify multiple directories by separating them with `:`. |
| `@per-project-session-fzf-opts`            | `'-d 15'`                   | The options to pass to `fzf-tmux`. Please see `man fzf` for available options.                                                                                        |
| `@per-project-session-destroy-unnamed`     | `on`                        | If set to on, unnamed session will be destroyed when switching a session.                                                                                             |
