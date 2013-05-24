#!/bin/sh

if [ -e /var/log/journal ]; then
    echo '/var/log/journal exists; not moving journal'
    return
fi

echo "switching journal output to disk"

journal=/sysroot/var/log/upgrade.journal

# back up old journal, if present
[ -e $journal ] && rm -rf $journal.old && mv $journal $journal.old

# make output dir and link to it
mkdir -p $journal /var/log
ln -sf $journal /var/log/journal

# tell journald to start writing to /var/log/journal
systemctl kill --kill-who=main --signal=SIGUSR1 systemd-journald.service
