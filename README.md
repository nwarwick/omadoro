# omadoro

A pomodoro timer for [Omarchy](https://omarchy.org) / Hyprland setups, built on
[`uair`](https://github.com/metent/uair) with a Waybar status module and Hyprland
keybindings.

- One key to start, one key to stop (`SUPER+ALT+P`)
- Waybar module that hides itself when the timer isn't running
- Cycle of 4× 25-minute work sessions with 5-minute breaks, then a 15-minute long break
- Desktop notifications on session boundaries via `notify-send`

## Requirements

- `uair` (and `uairctl`)
- `waybar`
- `libnotify` (for `notify-send`)
- Hyprland

On Arch:

```sh
pacman -S uair waybar libnotify
```

## Install

```sh
git clone https://github.com/<your-username>/omadoro.git
cd omadoro
./install.sh
```

The installer will:

- Drop `uair-toggle` and `uair-status` into `~/.local/bin/`
- Write `~/.config/uair/uair.toml` (only if you don't already have one)
- Write `~/.config/hypr/pomodoro.conf` and tell you the `source = ...` line to add
  to your `hyprland.conf`
- Print the Waybar JSONC + CSS snippets you need to paste by hand (Waybar config
  can't be merged automatically without risking your existing setup)

## Keybindings

| Keys | Action |
|---|---|
| `SUPER+ALT+P` | Start the timer / stop it if running |
| `SUPER+ALT+N` | Skip to next session |
| `SUPER+ALT+B` | Back to previous session |
| `SUPER+ALT+R` | Restart the cycle from `work-1` |

The Waybar module mirrors these:

| Mouse | Action |
|---|---|
| Left click | Start/stop |
| Right click | Restart cycle |
| Scroll up | Next session |
| Scroll down | Previous session |

## Customizing the cycle

Edit `~/.config/uair/uair.toml`. Each `[[sessions]]` block defines one phase. The
default cycle is the classic 4×25/5 pattern with a 15-minute long break, but the
session list is just a sequence — feel free to lengthen, shorten, or rearrange.

The `command` field on each session runs when that session ends, which is how the
notifications work. Replace it with anything you like (sound, script, etc.).

## Customizing notification messages

End-of-session notifications are picked at random from three pools defined in
`~/.local/bin/uair-notify`: `work_done`, `break_done`, and `cycle_done`. Add or
edit messages directly in that script. The pools are plain bash arrays — no
syntax to learn.

Note: re-running `install.sh` will overwrite your edits to `uair-notify`. If you
plan to customize, either skip reinstalling or copy the script somewhere safe
first.

## Uninstall

```sh
./uninstall.sh
```

Removes the scripts and Hyprland snippet. Leaves `uair.toml` and the Waybar edits
in place — those may contain customizations, so the script doesn't touch them.

## License

MIT
