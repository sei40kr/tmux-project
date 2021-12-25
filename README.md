# tmux-ghq

Select a [ghq](https://github.com/x-motemen/ghq) repository & create a session for it.

## Dependencies

- [ghq](https://github.com/x-motemen/ghq)
- [fzf](https://github.com/junegunn/fzf) with `fzf-tmux`

## Keybindings

| Keybinding (default) | Description                                                                                             |
|:---------------------|:--------------------------------------------------------------------------------------------------------|
| `prefix + g`         | Select a repository & create a new session for it. If the session already exists, switch to it instead. |

## Install

### Installation with [tpm](https://github.com/tmux-plugins/tpm) (recommended)

Add the following line to your `.tmux.conf`.

```tmux
set -g @plugin 'sei40kr/tmux-ghq'
```

## Customization

| Variable                   | Default value      | Description    |
|:---------------------------|:-------------------|:---------------|
| `@ghq-create-or-switch-to` | `g` (`prefix + g`) | The keybinding |

### Environment Variables

| Variable            | Default value                    | Description                     |
|:--------------------|:---------------------------------|:--------------------------------|
| `FZF_TMUX_OPTS`     | `''`                             | Default options for fzf-tmux    |
| `FZF_TMUX_GHQ_OPTS` | `--prompt "Switch to project: "` | Additional options for fzf-tmux |

## Tips

### Integrate ghq with Projectile

You can integrate ghq with
[Projectile](https://docs.projectile.mx/projectile/index.html)'s
[Automated Project Discovery](https://docs.projectile.mx/projectile/usage.html#automated-project-discovery).

To discover ghq projects (repositories) from Projectile, add the ghq root
directory to `projectile-project-search-path`.

```emacs-lisp
(setq projectile-project-search-path '(("~/ghq" . 3)))
```

Alternatively, you can utilize [emacs-ghq](https://github.com/rcoedo/emacs-ghq)
to find the root directory.

```emacs-lisp
(with-eval-after-load 'projectile
  (require 'ghq)
  (setq projectile-project-search-path (append `((,ghq--root . 3)) projectile-project-search-path)))
```
