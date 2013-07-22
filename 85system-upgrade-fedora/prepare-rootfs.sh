#!/bin/sh

die() { warn "$*"; exit 1; }

# Check whether converts needs to be run
if [ ! -L "${NEWROOT}/bin" ]; then
    convertfs "${NEWROOT}" || die "Unable to convert root filesystem"
fi
