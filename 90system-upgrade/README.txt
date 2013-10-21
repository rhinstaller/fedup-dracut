system-upgrade
==============
Will Woods <wwoods@redhat.com>
// vim: syn=asciidoc tw=78:

This module adds targets suitable for system upgrades.

The upgrade workflow is something like this:

. Using the *new* distro version, create an initramfs with `system-upgrade`.
    * Any other module starting with `system-upgrade-` will be included, e.g.:
      * distro-specific upgrade tool
      * distro-specific migration scripts
      * package-specific migration scripts
. Boot the *new* kernel + initramfs on the system to be upgraded.
    * root device is discovered
    * distro-specific filesystem migration tasks happen here, using
      the `pre-mount` hook
    * root device is mounted at `$NEWROOT`
    * initramfs copies the `$NEWROOT/system-upgrade` symlink to
      `/run/system-upgrade`
    * initramfs contents will be copied to `$NEWROOT/system-upgrade-root`
    * initramfs does a `switch-root` to the "real" root filesystem
. The system mounts its local disks.
. The system prepares `/system-upgrade-root`
    * Mounted filesystems are bind-mounted to `/system-upgrade-root/sysroot`
    * distros can unpack their `upgrade.img` into `/system-upgrade-root` here
. The system does a `switch-root` back into the initramfs
    * This time we're going to `upgrade.target` instead
. The `upgrade-pre` service/hook runs
    * After=`upgrade.target`
. The `upgrade` service/hook runs
    * distro-specific upgrade tools should run here
. The `upgrade-post` service/hook runs
. The system is rebooted.

It's probably a good idea to take a filesystem snapshot in `pre-mount` or
`pre-pivot`. If anything goes wrong, restore the snapshot in `upgrade-post`.
