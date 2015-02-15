#!/bin/sh

cat /data/.pabx/pabx_settings_fsc        > /sys/devices/i2c-0/0-0036/leds/lm3533-lcd-bl/fsc
cat /data/.pabx/pabx_settings_vibra      > /sys/devices/virtual/timed_output/vibrator/vib_level
cat /data/.pabx/pabx_settings_double_tap > /sys/devices/virtual/input/input1/wakeup_gesture


# stop qcfqd from shutting down CPUs
stop qcfqd

# bring up all CPUs for configuration
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

# set minfreq for all cores, does nothing if the file does not exist
cat /data/.pabx/pabx_settings_minfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
cat /data/.pabx/pabx_settings_minfreq > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
cat /data/.pabx/pabx_settings_minfreq > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
cat /data/.pabx/pabx_settings_minfreq > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq

cfg_gov=`cat /data/.pabx/pabx_settings_governor`
case "$cfg_gov" in
    "unmanaged")
        ;;
    "ondemand")
    echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
    echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
    echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
    echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
    echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
    echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
    echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
    echo 918000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
    echo 384000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
    echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
        ;;
    "ondemand_conservative")
    echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
    echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
    echo 40000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
    echo 95 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
    echo 0 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
    echo 2 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
    echo 5 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
    echo 60 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
    echo 810000  > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
    echo 810000  > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
    echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
        ;;
    *)
    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
    echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
    echo 1026000 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
    echo 30000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
    chown system /sys/devices/system/cpu/cpufreq/interactive/boostpulse
        ;;
    esac

# start qcfqd again - this will also re-disable the online cores
start qcfqd
