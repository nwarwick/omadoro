# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A pomodoro timer for Hyprland/Omarchy that's a thin layer over [`uair`](https://github.com/metent/uair). The repo is pure bash + config snippets — there is no build, no test suite, no linter. "Running" the project means installing it onto a host with Hyprland and Waybar.

## Commands

- `./install.sh` — copies `bin/*` to `~/.local/bin/`, installs `config/uair.toml` to `~/.config/uair/` (only if absent), drops `snippets/hypr-pomodoro.conf` into `~/.config/hypr/`, and prints the Waybar snippets to paste manually. Checks for `uair`, `uairctl`, `waybar`, `notify-send` and exits if any are missing.
- `./uninstall.sh` — removes the installed scripts and the Hyprland snippet. Deliberately leaves `uair.toml` and Waybar edits in place because they may be customized.
- `shellcheck bin/* install.sh uninstall.sh` — run before changes if available; the project has no CI but the scripts use `set -euo pipefail` and should stay shellcheck-clean.
- After editing scripts, re-run `./install.sh` to pick up changes (it overwrites `bin/*` unconditionally).

## Architecture

Four small bash scripts in `bin/` wrap `uairctl`. They're glued together by `config/uair.toml` (the session list) and the Hyprland/Waybar snippets (the input surface).

- **`uair-toggle`** — start/stop. If the `uair` daemon is running, `pkill` it. Otherwise `setsid -f uair` to detach it from the parent shell, then `uairctl resume` (uair starts paused).
- **`uair-jump {next|prev|restart}`** — navigation. **Important non-obvious behavior: `uairctl next`/`prev`/`jump` all leave the new session paused.** This script always follows up with `uairctl resume` so navigation feels like skipping rather than skipping-and-pausing. `restart` is implemented as `uairctl jump work-1`, so the session id `work-1` in `uair.toml` is load-bearing — don't rename it without updating this script.
- **`uair-status`** — long-running Waybar producer. Loops every 1s emitting JSON. When the daemon isn't running, emits `{"text":""}` so Waybar hides the module (this is why the module disappears between sessions).
- **`uair-notify {work|break|cycle}`** — fires `notify-send` with a random message from one of three bash arrays at the top of the script. Invoked from each session's `command` field in `uair.toml`. The arrays are the intended customization surface.

### Config flow

`config/uair.toml` defines the cycle (4×25min work + 5min break, then a 15min long break) as a flat list of `[[sessions]]`. Each session's `command` field calls `uair-notify` with the appropriate phase. uair runs through the list once per cycle — there is no looping primitive; "restart" means jumping back to `work-1`.

### Install surfaces (and why they differ)

- `~/.local/bin/uair-*` — overwritten on every `install.sh` run.
- `~/.config/uair/uair.toml` — preserved if present (likely customized).
- `~/.config/hypr/pomodoro.conf` — preserved if present. The user must add `source = ~/.config/hypr/pomodoro.conf` to `hyprland.conf` themselves; `install.sh` only checks for it and prints the line.
- Waybar (`config.jsonc` + `style.css`) — never auto-edited. The installer prints the snippets for manual paste because merging JSONC/CSS without breaking the user's existing config isn't safe.

**Caveat: `uair-notify` is overwritten by reinstall.** Users editing message pools will lose changes on `./install.sh`. The README warns about this; preserve that behavior unless explicitly changing the install model.

## Conventions

- All scripts use `#!/bin/bash` and (where practical) `set -euo pipefail`.
- Scripts must be idempotent and safe to run when the daemon isn't running — most paths swallow errors with `2>/dev/null` and `|| true`.
- Keep the Waybar JSON output single-line per tick; Waybar parses line-by-line.
- The session ids in `config/uair.toml` (especially `work-1`) are referenced by `bin/uair-jump`. Treat them as part of the public contract between the two files.
