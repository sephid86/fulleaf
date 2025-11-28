#!/usr/bin/env bash

# CPU 온도일 가능성이 높은 이름들 목록
CPU_NAMES=("coretemp" "k10temp" "x86_pkg_temp" "acpitz")

while true; do
    TEMP_VAL="0"
    FOUND=false

    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon_dir/name" ]; then
            zone_name=$(cat "$hwmon_dir/name")

            for cpu_name in "${CPU_NAMES[@]}"; do
                if [ "$zone_name" == "$cpu_name" ]; then
                    TEMP_FILE=$(ls "$hwmon_dir"/temp*_input | head -n 1)
                    
                    if [ -f "$TEMP_FILE" ]; then
                        temp_milli=$(cat "$TEMP_FILE")
                        TEMP_VAL=$((temp_milli / 1000))
                        FOUND=true
                        break 2
                    else
                        echo "fail"
                    fi
                fi
            done
        fi
    done

    if [ "$FOUND" = false ]; then
        echo "fail"
    fi

    # Eww로 온도 값 출력
    echo "$TEMP_VAL"

    # 1초 대기
    sleep 1
done
