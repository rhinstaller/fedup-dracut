#!/bin/bash
# actually perform the upgrade, using UPGRADEBIN (set in /etc/conf.d)

do_upgrade() {
    local args="" rv=0
    getargbool 0 rd.upgrade.test && args="$args --testing"
    getargbool 0 rd.upgrade.verbose && args="$args --verbose"
    getargbool 0 rd.upgrade.debug && args="$args --debug"

    # enable plymouth output unless specifically disabled
    getargbool 1 plymouth.enable && args="$args --plymouth"

    # Force selinux into permissive mode unless booted with 'enforcing=1'.
    # FIXME: THIS IS A BIG STUPID HAMMER AND WE SHOULD ACTUALLY SOLVE THE ROOT
    # PROBLEMS RATHER THAN JUST PAPERING OVER THE WHOLE THING. But this is what
    # Anaconda did, and upgrades don't seem to work otherwise, so...
    if [ -f /sys/fs/selinux/enforce ]; then
        enforce=$(< /sys/fs/selinux/enforce)
        getargbool 0 enforcing || echo 0 > /sys/fs/selinux/enforce
    fi
    # Some bugs this works around:
    # https://bugzilla.redhat.com/show_bug.cgi?id=841451
    # https://bugzilla.redhat.com/show_bug.cgi?id=844167
    # others to be filed (mysterious initramfs without kernel modules, etc.)

    # and off we go...
    $UPGRADEBIN --root=/sysroot $args
    rv=$?

    # restore things twiddled by workarounds above. TODO: remove!
    if [ -f /sys/fs/selinux/enforce ]; then
        echo $enforce > /sys/fs/selinux/enforce
    fi
    return $rv
}

[ ! -x "$UPGRADEBIN" ] && warn "upgrade binary '$UPGRADEBIN' missing!" && return

do_upgrade || exit $?
