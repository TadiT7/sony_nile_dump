#!/system/bin/sh
# Copyright (c) 2015, Compal Electronics, Inc.
# Copyright (c) 2017, Compal Electronics, Inc.
# All Rights, including trade secret rights, Reserved.
# 
# This script is part of the wifi mac address access solution which is used only in 
# Qualcomm Mobile platform Connectivity solution.
# 
# This script is used to check if file wlan_mac.bin exist and have correct wifi mac address when system bootup.
#

LOG_TAG="wifimac-bootup"
LOG_NAME="${0}:"

readMacAgain="false"

loge ()
{
  /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
}

logi ()
{
  /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

logi "Start to read WiFi Mac address from file wlan_mac.bin when system bootup"
/system/bin/wifimactool -r

case $? in

    0)
    logi "ok! read WiFi Mac address from wlan_mac.bin done."
    readMacAgain="false"
    ;;

    *)
    loge "fail! something wrong! We should read file again"
    readMacAgain="true"
    ;;

esac

if [ "$readMacAgain" = "true" ]; then
    logi "We read file wlan_mac.bin again in case wifi mac address really exist."
    /system/bin/wifimactool -r
else
    logi "We do not have to read wifi mac address again."
fi

logi "start to get wifi mac address property."

sleep 1

wifimacstring=`getprop persist.sys.wifi.mac.persist`

if [ "$wifimacstring" = "" ]; then
    logi "wifi mac address property does not exist !"
else
    logi "wifi mac address property exist! -> $wifimacstring"
fi

sleep 1

p2pmacstring=`getprop persist.sys.p2p.mac.persist`

if [ "$p2pmacstring" = "" ]; then
    logi "p2p mac address property does not exist !"
else
    logi "p2p mac address property exist! -> $p2pmacstring"
fi

exit 0
