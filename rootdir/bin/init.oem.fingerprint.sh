#!/vendor/bin/sh
#
# Identify fingerprint sensor model
#
# Copyright (c) 2019 Lenovo
# All rights reserved.
#
# Changed Log:
# ---------------------------------
# April 15, 2019  chengql2@lenovo.com  Initial version
# April 28, 2019  chengql2  Add fps_id creating step
#

script_name=${0##*/}
script_name=${script_name%.*}
function log {
    echo "$script_name: $*" > /dev/kmsg
}

utag_name_fps_id=fps_id
utag_fps_id=/proc/hw/$utag_name_fps_id

FPS_VENDOR_EGIS=egis
FPS_VENDOR_FPC=fpc
FPS_VENDOR_NONE=none

PROP_FPS_IDENT=vendor.hw.fps.ident
MAX_TIMES=20

function ident_fps {
    log "- install FPC driver"
    insmod /vendor/lib/modules/fpc1020_mmi.ko
    sleep 1
    log "- identify FPC sensor"
    setprop $PROP_FPS_IDENT ""
    start fpc_ident
    for i in $(seq 1 $MAX_TIMES)
    do
        sleep 0.1
        ident_status=$(getprop $PROP_FPS_IDENT)
        log "- reuslt: $ident_status"
        if [ $ident_status == $FPS_VENDOR_FPC ]; then
            log "ok"
            echo $FPS_VENDOR_FPC > $utag_fps_id/ascii
            return 0
        elif [ $ident_status == $FPS_VENDOR_NONE ]; then
            log "fail"
            log "- remove FPC driver"
            rmmod fpc1020_mmi
            break
        fi
    done

    log "- install Egis driver"
    insmod /vendor/lib/modules/ets_fps_mmi.ko
    echo $FPS_VENDOR_EGIS > $utag_fps_id/ascii
    return 0
}

utag_reload=/proc/hw/reload

status=$(cat $utag_reload)
if [ $status == 2 ]; then
    log "start to reload utag procfs ..."
    echo "1" > $utag_reload
    status=$(cat $utag_reload)
    while [ $status == 1 ]; do
        sleep 1
        status=$(cat $utag_reload)
    done
    log "finish"
fi

utag_new=/proc/hw/all/new

if [ ! -d $utag_fps_id ]; then
    log "- create utag: $utag_name_fps_id"
    echo $utag_name_fps_id > $utag_new
    ident_fps
    return $?
fi

fps_vendor=$(cat $utag_fps_id/ascii)
log "FPS vendor: $fps_vendor"

if [ $fps_vendor == $FPS_VENDOR_EGIS ]; then
    log "- install Egis driver"
    insmod /vendor/lib/modules/ets_fps_mmi.ko
    return $?
fi

if [ $fps_vendor == $FPS_VENDOR_FPC ]; then
    log "- install FPC driver"
    insmod /vendor/lib/modules/fpc1020_mmi.ko
    return $?
fi

ident_fps
return $?
