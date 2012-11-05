#!/bin/sh

export UPGRADEROOT=/system-upgrade-root
export UPGRADELINK=/system-upgrade

if getargbool 0 upgrade rd.upgrade; then
    export UPGRADE=1
fi
