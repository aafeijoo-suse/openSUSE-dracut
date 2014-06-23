#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

_modprobe_d=/etc/modprobe.d
if [ -d /usr/lib/modprobe.d ] ; then
    _modprobe_d=/usr/lib/modprobe.d
elif [ -d /lib/modprobe.d ] ; then
    _modprobe_d=/lib/modprobe.d
elif [ ! -d $_modprobe_d ] ; then
    mkdir -p $_modprobe_d
fi

for i in $(getargs rd.driver.pre -d rdloaddriver=); do
    (
        OLDIFS="$IFS"
        IFS=,
        for p in $i; do
            modprobe $p 2>&1 | vinfo
        done
        IFS="$OLDIFS"
    )
done


[ -d /etc/modprobe.d ] || mkdir -p /etc/modprobe.d

for i in $(getargs rd.driver.blacklist -d rdblacklist=); do
    (
        OLDIFS="$IFS"
        IFS=,
        for p in $i; do
            echo "blacklist $p" >>  $_modprobe_d/initramfsblacklist.conf
        done
        IFS="$OLDIFS"
    )
done

for p in $(getargs rd.driver.post -d rdinsmodpost=); do
    echo "blacklist $p" >>  $_modprobe_d/initramfsblacklist.conf
    _do_insmodpost=1
done

[ -n "$_do_insmodpost" ] && initqueue --settled --unique --onetime insmodpost.sh
unset _do_insmodpost _modprobe_d
