#!/bin/sh

die() { warn "$*"; exit 1; }

upgradedir="${NEWROOT}/system-upgrade-root"

[ -d "$upgradedir" ] || die "'$upgradedir' doesn't exist"

echo "saving initramfs to $upgradedir"

mount -t tmpfs -o mode=755 tmpfs "$upgradedir" \
    || die "Can't mount tmpfs for $upgradedir"

cp -ax / "$upgradedir" || die "failed to save initramfs to $upgradedir"

# switch off initrd mode
rm -f "$upgradedir/etc/initrd-release"
# make sure we have os-release
ln -sf "system-upgrade-release" "$upgradedir/etc/os-release"

# move SELinux policy into the right place so we can load it
mv $upgradedir/etc/selinux.hidden $upgradedir/etc/selinux
# copy the system's SELinux config, so we use the same settings/policy
cp -f $NEWROOT/etc/selinux/config $upgradedir/etc/selinux/config 2>/dev/null

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

# plymouthd will crash if it tries to load a plymouth module from a previous
# version that was ABI-incompatible (e.g. F17 label.so in F18 plymouthd).
plydir=lib/plymouth
[ -d /$plydir ] || plydir=lib64/plymouth
bind_into_newroot $plydir
