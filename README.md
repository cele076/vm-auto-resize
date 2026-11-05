# vm-auto-resize

Makes the guest resolution follow the VM window size. For KVM guests running XFCE (X11) on a Virtio GPU, viewed in virt-manager.

## Why it's needed

With **View → Resize to VM → Auto resize VM with window** enabled, the host tells the virtio-gpu the new window size, and the GPU reports a new preferred mode for `Virtual-1`. XFCE doesn't apply that mode, so the screen stays at its old size. KDE does, which is why resizing works out of the box there. `spice-vdagent` isn't involved: the host sends it no monitor-config message for virtio-gpu.

`vm-auto-resize` is a small watcher that applies the preferred mode on each display change.

## Install

```sh
./install.sh
```

This installs the files below. Run it again to update. It takes effect at the next login.

| File | Installed to | Purpose |
| --- | --- | --- |
| `vm-auto-resize` | `~/.local/bin/vm-auto-resize` | Watches `drm` events with `udevadm monitor` and sets each output to its preferred mode, only if the current mode differs. |
| `vm-auto-resize.desktop` | `~/.config/autostart/vm-auto-resize.desktop` | Starts the watcher at login. `@BIN@` is replaced with the install directory. |

The "only if different" check matters. Applying a mode emits another change event, and a version that called `xrandr --auto` unconditionally looped and killed X.

## Requirements

- virt-manager with auto-resize enabled as above.
- Guest video model: Virtio.

## Check it

```sh
pgrep -f '[v]m-auto-resize' | wc -l   # expect 3 (the script and its pipeline)
xrandr | head -n 2                    # current size should match the window
```

Use the bracket pattern. `pgrep -f` or `pkill -f` with the plain name also matches the shell running the command.

## Troubleshooting

- **Black screen after a resize:** restart the VM, then remove `~/.config/autostart/vm-auto-resize.desktop`.
- **No resize at all:** check that the watcher is running. Then run `udevadm monitor --udev --subsystem-match=drm` and resize the window; a `change` line should appear.
- **Debugging `spice-vdagentd`:** use `-d -x`. Don't use `-f`: it means `--fake-uinput` and floods the log with `write /dev/uinput: Invalid argument`, which doesn't happen in normal operation.
