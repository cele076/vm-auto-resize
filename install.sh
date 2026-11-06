#!/bin/sh
# Install the auto-resize watcher for the current user.
set -e
here=$(cd "$(dirname "$0")" && pwd)
bin=${XDG_BIN_HOME:-$HOME/.local/bin}
autostart=${XDG_CONFIG_HOME:-$HOME/.config}/autostart

mkdir -p "$bin" "$autostart"
install -m 755 "$here/vm-auto-resize" "$bin/vm-auto-resize"
install -m 755 "$here/vm-auto-resize-recover" "$bin/vm-auto-resize-recover"
sed "s|@BIN@|$bin|" "$here/vm-auto-resize.desktop" > "$autostart/vm-auto-resize.desktop"
# Ctrl+Alt+R runs the recovery script (XFCE). Skipped where xfconf is not running.
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>r" -n -t string -s "$bin/vm-auto-resize-recover" 2>/dev/null \
    || echo "Could not set the Ctrl+Alt+R shortcut; bind $bin/vm-auto-resize-recover manually."
echo "Installed. Takes effect at next login, or run: setsid $bin/vm-auto-resize >/dev/null 2>&1 &"
