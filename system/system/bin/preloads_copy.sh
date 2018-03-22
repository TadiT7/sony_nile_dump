#!/system/bin/sh
#
# Copyright (C) 2016 The Android Open Source Project
# Copyright (C) 2017 Sony Mobile Communications Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# This script copies preloaded content from system_b to data partition
# create files with 644 (global read) permissions.
#
# NOTE: This file has been modified by Sony Mobile Communications Inc.
# Modifications are licensed under the License.

umask 022
log -p i -t preloads_copy "Copying preloads from x_other"
if [ $# -eq 1 ]; then
  # Where the system_b is mounted that contains the preloads dir
  mountpoint=$1
  dest_dir=/data/preloads
  log -p i -t preloads_copy "Copying from $mountpoint/preloads"
  # Parallelize by copying subfolders and files in the background
  for file in $(find ${mountpoint}/preloads -mindepth 1 -maxdepth 1); do
      log -p i -t preloads_copy "cp -rn '$file' '$dest_dir'"
      cp -rn $file $dest_dir &
  done
  # Wait for jobs to finish
  wait
  log -p i -t preloads_copy "Copying complete"
  exit 0
else
  log -p e -t preloads_copy "Usage: preloads_copy.sh <system_other-mount-point>"
  exit 1
fi
