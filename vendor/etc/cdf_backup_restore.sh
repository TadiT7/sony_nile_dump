#!/system/bin/sh

# Copyright (C) 2017 Sony Mobile Communications Inc.

input=$1
ls=/vendor/bin/ls
cp=/vendor/bin/cp
rm=/vendor/bin/rm
mkdir=/vendor/bin/mkdir
chmod=/vendor/bin/chmod
chown=/vendor/bin/chown
restorecon=/vendor/bin/restorecon
backup_media_0_dir=/data/backup_cdf_data/0
backup_app_dir=/data/backup_cdf_data/app
data_media_0=/data/media/0
data_media=/data/media
data_app=/data/app

crypto_type=`getprop ro.crypto.type`
first_boot=`cat /data/.layout_version`

if [ "$crypto_type" == "file" ]; then
    echo "FBE Enabled build\n"

    # Check for first boot
    if [ -f /data/.layout_version ]; then
        first_boot=`cat /data/.layout_version`
    else
        first_boot="0"
    fi

    # Backup Contents
    if [ "$input" == "backup" -a $first_boot -lt 3 ]; then
        $mkdir -m 775 $backup_media_0_dir
        $mkdir -m 775 $backup_app_dir
        $chown media_rw:media_rw $backup_media_0_dir
        $chown system:system $backup_app_dir
        $restorecon -RF $backup_media_0_dir
        $restorecon -RF $backup_app_dir
        # Backup /data/media/0
        if [ -e "${backup_media_0_dir}" ]; then
            for i in $(ls ${data_media_0}); do
                echo "Moving $data_media_0/$i to $backup_media_0_dir\n"
                $cp -a $data_media_0/$i $backup_media_0_dir
                if [ $? -eq 0 ] ; then
                    $rm -r $data_media_0/$i
                fi
            done
            $rm -r $data_media
            $restorecon -RF $backup_media_0_dir
        fi

        # Backup /data/app
        if [ -e "${backup_app_dir}" ]; then
            for i in $(ls ${data_app}); do
                echo "Moving $data_app/$i to $backup_app_dir\n"
                $cp -a $data_app/$i $backup_app_dir
                if [ $? -eq 0 ] ; then
                    $rm -r $data_app/$i
                fi
            done
            $rm -r $data_app
            $restorecon -RF $backup_app_dir
        fi
    # Restore Content
    elif [ "$input" == "restore_media" ]; then
          # Restore backup contents to /data/media/0
          if [ \( ! -d $backup_media_0_dir \) ]; then
              echo "No media restore directory exist\n"
              exit 1
          fi

          if [ -e "${data_media_0}" ]; then
              for i in $(ls ${backup_media_0_dir}); do
                  echo "Moving $backup_media_0_dir/$i to $data_media_0\n"
                  $cp -a $backup_media_0_dir/$i $data_media_0
                  if [ $? -eq 0 ] ; then
                      $rm -r $backup_media_0_dir/$i
                  fi
              done
              $restorecon -RF $data_media_0
              $rm -r $backup_media_0_dir
          fi


    elif [ "$input" == "restore_app" ]; then
          if [ \( ! -d $backup_app_dir \) ]; then
              echo "No app restore directory exist\n"
              exit 1
          fi

          # Restore backup contents to /data/app
          if [ -e "${data_app}" ]; then
              for i in $(ls ${backup_app_dir}); do
                  echo "Moving $backup_app_dir/$i to $data_app\n"
                  $cp -a $backup_app_dir/$i $data_app
                  if [ $? -eq 0 ] ; then
                      $rm -r $backup_app_dir/$i
                  fi
              done
              $restorecon -RF $data_app
              $rm -r $backup_app_dir
          fi
    fi
else
    echo "Not FBE Enabled build or not first boot\n"
fi
