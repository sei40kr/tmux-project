# tmux-per-project-session

A project-oriented session manager for tmux.

## Requirements

- sed
- [fzf](https://github.com/junegunn/fzf) (with `fzf-tmux`)
- [fd](https://github.com/sharkdp/fd) (optional)

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the plugin to the list of TPM plugins in your `.tmux.conf` like below:

```tmux
set -g @plugin 'sei40kr/tmux-per-project-session'
```

## Customization

| Variable                                             | Default Value               | Description                                                                                                                                                           |
| :--                                                  | :--                         | :--                                                                                                                                                                   |
| `@per-project-session-goto`                          | `g`                         | A key binding to switch a session. The default is `prefix + g`.                                                                                                       |
| `@per-project-session-workspace-dirs`                | `${HOME}/develop/workspace` | Workspace directories. You can specify multiple directories by separating them with `:`.                                                                              |
| `@per-project-session-workspace-maxdepth`            | `2`                         | The number of max levels below the workspace directories to search projects.                                                                                          |
| `@per-project-session-known-project-dirs`            | `''`                        | Project directories outside the workspace directories. For example, you can put `~/.dotfiles` here. You can specify multiple directories by separating them with `:`. |
| `@per-project-session-fzf-opts`                      | `'-d 15'`                   | The options to pass to `fzf-tmux`. Please see `man fzf` for available options.                                                                                        |
| `@per-project-session-open-terminal-for-new-session` | `off`                       | If set to `on`, open a new session in another terminal window. Please see Tips below this section for details.                                                        |
| `@per-project-session-terminal-cmd`                  | `''`                        | Command to open a new terminal window. For example, if you're using Alacritty, this will be `alacritty -e`.                                                           |
| `@per-project-session-destroy-unnamed`               | `on`                        | If set to on, unnamed session will be destroyed when switching a session.                                                                                             |

## Tips

### Open a new session in another terminal window

If you set `@per-project-session-open-terminal-for-new-session` to `on`, you can open a new session in another terminal window. This is very useful with a tiling window manager.

You'll also need to set the title of terminal windows to find an existing terminal with the session you want to switch to.

```tmux
set-option -g @per-project-session-open-terminal-for-new-session on
set-option -g set-titles on
# avoid using any variables in set-titles-string except for #S
set-option -g set-titles-string 'Alacritty@#S'
# run `alacritty -e $SHELL -c 'tmux attach-session -t <session name>'` 
# when opening a new terminal window
set-option -g @per-project-session-terminal-cmd 'alacritty -e'
# recommended
set-option -g detach-on-destroy on
```

## Similar Projects

- [zsh-fzf-projects](https://github.com/sei40kr/zsh-fzf-projects) - If you don't need tmux integration, use this instead.
