#!/bin/sh

# upgrade-post hook: last-minute fixes, cleanups, etc.
echo "starting upgrade-post hook"

export DRACUT_SYSTEMD=1
if [ -f /dracut-state.sh ]; then
    . /dracut-state.sh 2>/dev/null
fi
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

source_conf /etc/conf.d

getarg 'rd.upgrade.break=post' 'rd.break=upgrade-post' && \
    emergency_shell -n upgrade-post "Break before upgrade-post hook"
source_hook upgrade-post

# absolutely godawful hack workaround garbage that I am ashamed of:
# Since we can't figure out how to unmount the root device properly
# (it's inaccessable because we moved system-upgrade-root on top of it)
# we need some other way to make sure all the data that might be pending
# actually gets written to disk. So...

startmsg="upgrade-post pid $$ doing emergency sync"
echo 1 > /proc/sys/kernel/sysrq  # enable sysrq
echo "$startmsg" > /dev/kmsg     # add marker to dmesg
echo s > /proc/sysrq-trigger     # start sync
for ((i=0; i<20; i++)); do       # wait up to 20s for sync to finish
    dmesg | sed "1,/$startmsg/d" | grep -q 'Emergency Sync complete' && break
    sleep 1
done
sleep 2                          # sleep a little more just to be sure

exit 0
