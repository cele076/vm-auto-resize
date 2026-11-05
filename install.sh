#!/bin/sh
# Install the auto-resize watcher for the current user.
set -e
here=$(cd "$(dirname "$0")" && pwd)
bin=${XDG_BIN_HOME:-$HOME/.local/bin}
autostart=${XDG_CONFIG_HOME:-$HOME/.config}/autostart

mkdir -p "$bin" "$autostart"
install -m 755 "$here/vm-auto-resize" "$bin/vm-auto-resize"
sed "s|@BIN@|$bin|" "$here/vm-auto-resize.desktop" > "$autostart/vm-auto-resize.desktop"
echo "Installed. Takes effect at next login, or run: setsid $bin/vm-auto-resize >/dev/null 2>&1 &"
