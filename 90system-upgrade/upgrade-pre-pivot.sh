#!/bin/sh

if [ -d "${NEWROOT}${UPGRADEROOT}" ] && [ -L "${NEWROOT}${UPGRADELINK}" ]; then
    {
        echo "UPGRADEROOT=$UPGRADEROOT"
        echo "UPGRADELINK=$UPGRADELINK"
        echo "NEWROOT=$NEWROOT"
        echo "NEWINIT=$NEWINIT"
    } > /run/initramfs/upgrade.conf
    plymouth change-mode --updates && plymouth system-update --progress=0
    # removing /run/initramfs/switch-root.conf disables initrd-switch-root
    rm -f /run/initramfs/switch-root.conf
    systemctl isolate upgrade-setup-root.target
fi
