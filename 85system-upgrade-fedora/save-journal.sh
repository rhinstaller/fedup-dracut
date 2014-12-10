#!/bin/sh

echo "all upgrade scripts finished"
echo "writing logs to disk and rebooting"

logfile=/sysroot/var/log/upgrade.log

# back up old logfile, if present
[ -e $logfile ] && rm -rf ${logfile}.old && mv $logfile ${logfile}.old

# write out the logfile
bootid=$(</proc/sys/kernel/random/boot_id); bootid=${bootid//-/}
echo "-- Boot ID: $bootid --" > $logfile
journalctl -b -a >> $logfile
