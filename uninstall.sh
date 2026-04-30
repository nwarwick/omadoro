#!/bin/bash
# Uninstaller for omadoro.
# Removes scripts and the Hyprland snippet. Leaves uair.toml and waybar edits alone
# — those may contain user customizations and should be cleaned up by hand.

set -euo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '  %s\n' "$*"; }
ok()    { printf '\033[32m✓ %s\033[0m\n' "$*"; }

bold "Stopping uair if running"
pkill -x uair 2>/dev/null || true
ok "Done"
echo

bold "Removing scripts"
rm -f "${HOME}/.local/bin/uair-toggle"
rm -f "${HOME}/.local/bin/uair-status"
rm -f "${HOME}/.local/bin/uair-notify"
rm -f "${HOME}/.local/bin/uair-jump"
ok "Scripts removed"
echo

bold "Removing Hyprland snippet"
rm -f "${HOME}/.config/hypr/pomodoro.conf"
ok "pomodoro.conf removed"
info "Remember to delete the matching 'source = ...' line from hyprland.conf"
echo

bold "Manual cleanup still required"
info "  • ~/.config/uair/uair.toml (kept in case you customized it)"
info "  • Waybar module + CSS in ~/.config/waybar/{config.jsonc,style.css}"
