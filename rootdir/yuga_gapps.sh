#!/bin/sh

#
# This script is used to automatically install
# the gapps copy located on /sdcard (hopefully mounted)
# IF gapps is not already installed on the device
#

MD5_GAPPS="00cb4261dc7fd42e3b6f9d78f5bb7821"
PTH_GAPPS="/data/media/0/gapps_50_yuga_004-00cb.tgz"

# only install gapps package if md5sum matches this: (cannot use sdcard as we are not multiuser yet)
echo "$MD5_GAPPS  $PTH_GAPPS" > /dev/.yg_gapps_md5

cd /

if ! grep -q '^tmpfs /data' /proc/mounts ; then
    if [ ! -f /system/priv-app/GoogleOneTimeInitializer/GoogleOneTimeInitializer.apk ] ; then
        if /system/xbin/md5sum -c /dev/.yg_gapps_md5 ; then
            # ok, md5sum of file is correct: let's install gapps
            mount -o remount,rw /system
            echo  25 > /sys/class/leds/lm3533-green/brightness
            /system/xbin/tar -xvf $PTH_GAPPS
            echo 255 > /sys/class/leds/lm3533-blue/brightness
            sync
            echo s > /proc/sysrq-trigger
            echo u > /proc/sysrq-trigger
            echo b > /proc/sysrq-trigger
        fi
    fi

    if [ -d /system/.pabx ] ; then
        mount -o remount,rw /system
        busybox mount --bind /system/.pabx/dalvik-cache /data/dalvik-cache
    fi

fi

# load radio-iris during boot (can not be compiled in-kernel due to sloppy coding)
## this will probably never work in android 5.0 :-(
#/system/bin/insmod /system/lib/modules/radio-iris-transport.ko


# tell init to continue
touch /dev/.yginstall_done

# we MAY get started again if we are in encryption mode
# we are therefore removing the trigger after some time
sleep 3
rm /dev/.yginstall_done
rm /dev/.yg_gapps_md5
