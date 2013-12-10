#!/bin/sh

# pause the progress meter - we'll start it back up when the upgrade starts
plymouth pause-progress

# make a backup copy of the link itself
cp -P ${NEWROOT}/system-upgrade /run/system-upgrade

# save system-upgrade-shell.service
mkdir -p /run/systemd/system/sysinit.target.wants
for d in system system/sysinit.target.wants; do
    mv -f /etc/systemd/$d/system-upgrade-shell.service /run/systemd/$d/
done

# fedup-0.7.x compat. drop this when 0.7.x is old & irrelevant.
if grep -qw 'systemd.unit=system-upgrade.target' /proc/cmdline; then
    echo "UPGRADEROOT=/system-upgrade-root" > /run/initramfs/upgrade.conf
    echo "UPGRADELINK=/system-upgrade" >> /run/initramfs/upgrade.conf
    ln -sf upgrade.target /etc/systemd/system/system-upgrade.target
fi
