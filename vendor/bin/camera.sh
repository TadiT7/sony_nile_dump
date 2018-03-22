#! /vendor/bin/sh

LOG_DIR="/sdcard/camera_log/"
LOG_TAG="cameralog"
LOG_FILE=`date +%Y%m%d%H%M%S`.log

/vendor/bin/logcat -v threadTime -f $LOG_DIR$LOG_FILE
