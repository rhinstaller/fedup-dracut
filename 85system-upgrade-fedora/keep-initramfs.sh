#!/bin/sh

die() { warn "$*"; exit 1; }

upgradedir="${NEWROOT}${UPGRADEROOT}"

[ -n "$UPGRADEROOT" ] || die "UPGRADEROOT is unset, can't save initramfs"
[ -d "$upgradedir" ] || die "'$upgradedir' doesn't exist"

echo "saving initramfs to $upgradedir"

mount -t tmpfs -o mode=755 tmpfs "$upgradedir" \
    || die "Can't mount tmpfs for $upgradedir"

cp -ax / "$upgradedir" || die "failed to save initramfs to $upgradedir"

moddir=lib/modules/$(uname -r)
echo "making /$moddir available inside $NEWROOT"
mount -o remount,rw $NEWROOT
mkdir -p $NEWROOT/$moddir
mount -o remount $NEWROOT
mount --bind $upgradedir/$moddir $NEWROOT/$moddir \
    || warn "failed to bind /$moddir into $NEWROOT"
