#!/bin/sh
if [ -f /run/initramfs/switch-root.conf ]; then
    systemctl --no-block isolate initrd-switch-root.target
fi
