# tmux-ghq

Select a [ghq](https://github.com/x-motemen/ghq) repository & create a session for it.

## Dependencies

- [ghq](https://github.com/x-motemen/ghq)
- [fzf](https://github.com/junegunn/fzf) with `fzf-tmux`

## Keybinds

| Keybind (default) | Description                                                                                             |
|:------------------|:--------------------------------------------------------------------------------------------------------|
| `prefix + g`      | Select a repository & create a new session for it. If the session already exists, switch to it instead. |

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the following line to your `.tmux.conf`.

```tmux
set -g @plugin 'sei40kr/tmux-ghq'
```

## Customization

| Variable                   | Default value      | Description |
|:---------------------------|:-------------------|:------------|
| `@ghq-create-or-switch-to` | `g` (`prefix + g`) | The keybind |

### Environment Variables

| Variable            | Default value                    | Description                     |
|:--------------------|:---------------------------------|:--------------------------------|
| `FZF_TMUX_OPTS`     | `''`                             | Default options for fzf-tmux    |
| `FZF_TMUX_GHQ_OPTS` | `--prompt "Switch to project: "` | Additional options for fzf-tmux |
