#!/bin/sh

die() { warn "$*"; exit 1; }

upgradedir="${NEWROOT}${UPGRADEROOT}"

[ -n "$UPGRADEROOT" ] || die "UPGRADEROOT is unset, can't save initramfs"
[ -d "$upgradedir" ] || die "'$upgradedir' doesn't exist"

echo "saving initramfs to $upgradedir"

mount -t tmpfs -o mode=755 tmpfs "$upgradedir" \
    || die "Can't mount tmpfs for $upgradedir"

cp -ax / "$upgradedir" || die "failed to save initramfs to $upgradedir"

bind_into_newroot() {
    local dir="$1"
    echo "making /$dir available inside $NEWROOT"
    if [ ! -d $NEWROOT/$dir ]; then
        # attempt to create the dir if it's not already present.
        # NOTE: this is somewhat unreliable and should be avoided if possible,
        # e.g. by making sure the required dirs exist before reboot
        mount -o remount,rw $NEWROOT
        mkdir -p $NEWROOT/$dir
        mount -o remount $NEWROOT
    fi
    mount --bind $upgradedir/$dir $NEWROOT/$dir \
        || warn "failed to bind /$dir into $NEWROOT"
    # leave a note for upgrade-prep.service
    > $NEWROOT/$dir/.please-unmount
}

# make our kernel modules available inside the system so we can load drivers
bind_into_newroot lib/modules/$(uname -r)
