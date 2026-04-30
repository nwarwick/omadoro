#!/bin/bash
# Installer for omadoro.
# Copies scripts, the uair config, and the Hyprland keybinding snippet into place.
# Prints the waybar pieces for manual paste — JSONC and CSS can't be merged safely
# without risking the user's existing config.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${HOME}/.local/bin"
UAIR_DIR="${HOME}/.config/uair"
HYPR_DIR="${HOME}/.config/hypr"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
warn()  { printf '\033[33m! %s\033[0m\n' "$*"; }
info()  { printf '  %s\n' "$*"; }
ok()    { printf '\033[32m✓ %s\033[0m\n' "$*"; }

check_dep() {
  if ! command -v "$1" >/dev/null 2>&1; then
    warn "Missing dependency: $1"
    return 1
  fi
}

bold "Checking dependencies"
missing=0
for dep in uair uairctl waybar notify-send; do
  check_dep "$dep" || missing=1
done
if [ "$missing" -eq 1 ]; then
  warn "Install missing packages and re-run. On Arch:  pacman -S uair waybar libnotify"
  exit 1
fi
ok "All dependencies present"
echo

bold "Installing scripts to ${BIN_DIR}"
mkdir -p "$BIN_DIR"
install -m 755 "${REPO_DIR}/bin/uair-toggle" "${BIN_DIR}/uair-toggle"
install -m 755 "${REPO_DIR}/bin/uair-status" "${BIN_DIR}/uair-status"
install -m 755 "${REPO_DIR}/bin/uair-notify" "${BIN_DIR}/uair-notify"
install -m 755 "${REPO_DIR}/bin/uair-jump" "${BIN_DIR}/uair-jump"
ok "uair-toggle, uair-status, uair-notify, and uair-jump installed"
echo

bold "Installing uair config"
mkdir -p "$UAIR_DIR"
if [ -f "${UAIR_DIR}/uair.toml" ]; then
  warn "${UAIR_DIR}/uair.toml already exists — leaving it untouched"
  info "Sample config available at: ${REPO_DIR}/config/uair.toml"
else
  install -m 644 "${REPO_DIR}/config/uair.toml" "${UAIR_DIR}/uair.toml"
  ok "uair.toml installed"
fi
echo

bold "Installing Hyprland keybindings"
mkdir -p "$HYPR_DIR"
HYPR_DEST="${HYPR_DIR}/pomodoro.conf"
if [ -f "$HYPR_DEST" ]; then
  warn "${HYPR_DEST} already exists — leaving it untouched"
else
  install -m 644 "${REPO_DIR}/snippets/hypr-pomodoro.conf" "$HYPR_DEST"
  ok "Wrote ${HYPR_DEST}"
fi
SOURCE_LINE="source = ~/.config/hypr/pomodoro.conf"
if grep -Fq "$SOURCE_LINE" "${HYPR_DIR}/hyprland.conf" 2>/dev/null; then
  ok "hyprland.conf already sources pomodoro.conf"
else
  warn "Add this line to ~/.config/hypr/hyprland.conf:"
  info "    ${SOURCE_LINE}"
  info "Then run:  hyprctl reload"
fi
echo

bold "Waybar — manual steps required"
info "Waybar uses JSONC and CSS, which can't be merged automatically without"
info "risking your existing config. Add the snippets below by hand."
echo
info "1. Paste the module block from:"
info "     ${REPO_DIR}/snippets/waybar-module.jsonc"
info "   into the top-level object of ~/.config/waybar/config.jsonc"
echo
info "2. Add \"custom/pomodoro\" to one of the modules arrays (modules-left/center/right)"
echo
info "3. Append the styles from:"
info "     ${REPO_DIR}/snippets/waybar-style.css"
info "   to ~/.config/waybar/style.css"
echo
info "4. Reload waybar:  pkill waybar && waybar &"
echo

bold "Done."
info "Press SUPER+ALT+P to start your first pomodoro."
