#!/bin/sh

# pause the progress meter - we'll start it back up when the upgrade starts
plymouth pause-progress

# make a backup copy of the link itself
cp -P ${NEWROOT}/system-upgrade /run/system-upgrade
