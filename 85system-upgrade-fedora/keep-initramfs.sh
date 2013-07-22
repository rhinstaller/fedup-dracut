#!/bin/sh

die() { warn "$*"; exit 1; }

upgradedir="${NEWROOT}${UPGRADEROOT}"

[ -n "$UPGRADEROOT" ] || die "UPGRADEROOT is unset, can't save initramfs"
[ -d "$upgradedir" ] || die "'$upgradedir' doesn't exist"

echo "saving initramfs to $upgradedir"

mount -t tmpfs -o mode=755 tmpfs "$upgradedir" \
    || die "Can't mount tmpfs for $upgradedir"

cp -ax / "$upgradedir" || die "failed to save initramfs to $upgradedir"

create_newroot_dir() {
    local newdir="$1"

    # Save the current mount options
    # mountinfo consists of lines of the form:
    # <mount-ID> <parent-ID> <major>:<minor> <root> <mount point> <options> <optional fields> ... - <fstype> <source> <super options>
    #
    # This loops assumes that $NEWROOT is a mount point and that we can
    # ignore <root>, since nothing should be mounted in a chroot jail yet
    local old_opts=""
    local mount_id parent_id major_minor root mount_point options rest
    while read -r mount_id parent_id major_minor root mount_point options \
            rest ; do
        if [ "$mount_point" = "$NEWROOT" ]; then
            old_opts="$options"
            break
        fi
    done < /proc/self/mountinfo
    if [ -z "$old_opts" ]; then
        old_opts="defaults"
    fi

    if [ ! -d "$NEWROOT/$newdir" ]; then
        # attempt to create the dir if it's not already present.
        # NOTE: this is somewhat unreliable and should be avoided if possible,
        # e.g. by making sure the required dirs exist before reboot
        mount -o remount,rw "$NEWROOT"
        mkdir -p "$NEWROOT/$newdir"
        mount -o remount,"$old_opts" "$NEWROOT"
    fi
}

bind_into_newroot() {
    local dir="$1"
    echo "making /$dir available inside $NEWROOT"
    create_newroot_dir "$dir"
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

# Create /run in $NEWROOT if not already available
create_newroot_dir run

# If $NEWROOT does not use systemd, mask out initrd-udevadm-cleanup-db since
# nothing will be repopulating the data
[ -x "$NEWROOT/usr/lib/systemd/systemd" ] || \
    ln -sf /dev/null /etc/systemd/system/initrd-udevadm-cleanup-db.service
