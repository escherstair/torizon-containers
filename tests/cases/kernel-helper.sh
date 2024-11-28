#!/usr/bin/env bash

# gpu_kernel_logs shall only be called after taking actions that may produce a
# log to be output to dmesg. See the first call to --clear and subsquent
# --read-clear, which wipes the logs before and inbetween runs.
gpu_kernel_logs() {
  logs=$(dmesg --read-clear | grep -i -E '(gpu|vivante|etnaviv|mali|gal|pvr)')
  echo "$logs"
  if echo "$logs" | grep -q -i 'fail'; then
    return 1
  else
    return 0
  fi
}

clean_kernel_logs() {
  dmesg --clear
}
