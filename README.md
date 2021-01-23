# tmux-per-project-session

A project-oriented session manager for tmux.

## Requirements

- [fzf](https://github.com/junegunn/fzf) with `fzf-tmux`
- (optional) [fd](https://github.com/sharkdp/fd)

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the following line to your `.tmux.conf`.

```tmux
set -g @plugin 'sei40kr/tmux-per-project-session'
```

## Customization

| Variable                                   | Default Value               | Description                                                                                                                                                           |
| :----------------------------------------- | :-------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `@per-project-session-switch`              | `g`                         | A key binding to switch a session. The default is `prefix + g`.                                                                                                       |
| `@per-project-session-workspace-dirs`      | `${HOME}/develop/workspace` | Workspace directories. You can specify multiple directories by separating them with `:`.                                                                              |
| `@per-project-session-workspace-max-depth` | `2`                         | The number of max levels below the workspace directories to search projects.                                                                                          |
| `@per-project-session-known-project-dirs`  | `''`                        | Project directories outside the workspace directories. For example, you can put `~/.dotfiles` here. You can specify multiple directories by separating them with `:`. |
| `@per-project-session-fzf-tmux-opts`       | `'-d 30%'`                   | The options to pass to `fzf-tmux`. Please see `man fzf` for available options.                                                                                        |

## Similar Projects

- [zsh-fzf-projects](https://github.com/sei40kr/zsh-fzf-projects) - If you don't need tmux integration, use this instead.
