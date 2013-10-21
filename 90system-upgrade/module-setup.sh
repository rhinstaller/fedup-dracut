#!/bin/bash
# ex: ts=8 sw=4 sts=4 et filetype=sh

upgrade_hooks="upgrade-pre upgrade upgrade-post"

check() {
    hookdirs+="$upgrade_hooks "
    return 255
}

depends() {
    echo "systemd"
    # pull in any other "system-upgrade-*" modules that exist
    local mod_dir mod
    for mod_dir in $dracutbasedir/modules.d/[0-9][0-9]*; do
        [ -d $mod_dir ] || continue
        mod=${mod_dir##*/[0-9][0-9]}
        strstr "$mod" "system-upgrade-" && echo $mod
    done
    return 0
}

install() {
    # Set UPGRADE env variable
    inst_hook cmdline 01 "$moddir/upgrade-init.sh"
    # Save copy of $NEWROOT/system-upgrade to /run
    inst_hook pre-pivot 99 "$moddir/upgrade-pre-pivot.sh"

    # NOTE: 98systemd copies units from here to /run/systemd/system so systemd
    #       won't lose our units after switch-root.
    unitdir="/etc/systemd/system"

    # Set up systemd target and units
    upgrade_wantsdir="${initdir}${unitdir}/upgrade.target.wants"

    inst_simple "$moddir/upgrade.target" "$unitdir/upgrade.target"

    mkdir -p "$upgrade_wantsdir"
    for s in $upgrade_hooks; do
        inst_simple "$moddir/$s.service" "$unitdir/$s.service"
        inst_script "$moddir/$s.sh"      "/bin/$s"
        ln -sf "../$s.service" $upgrade_wantsdir
    done

    # generator to switch to upgrade.target when we return to initrd
    generatordir="/usr/lib/systemd/system-generators"
    mkdir -p "${initdir}${generatordir}"
    inst_script "$moddir/initrd-system-upgrade-generator" \
                "$generatordir/initrd-system-upgrade-generator"

    # upgrade shell service
    sysinit_wantsdir="${initdir}${unitdir}/sysinit.target.wants"
    mkdir -p $sysinit_wantsdir
    inst_simple "$moddir/system-upgrade-shell.service" \
                "$unitdir/system-upgrade-shell.service"
    ln -sf "../system-upgrade-shell.service" $sysinit_wantsdir
}

