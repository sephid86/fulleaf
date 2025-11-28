#!/usr/bin/env bash

# ~/.config/eww/scripts/gpu_temp.sh

# GPU 이름 목록 (AMD 사용 시 'amdgpu', NVIDIA 사용 시 'nouveau' 등을 시도해 보세요)
GPU_NAMES=("amdgpu" "nouveau" "radeon")

# 이 스크립트는 'deflisten'으로 사용되므로 무한 루프가 필요합니다.
while true; do
    TEMP_VAL="0"
    FOUND=false

    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon_dir/name" ]; then
            zone_name=$(cat "$hwmon_dir/name")

            for gpu_name in "${GPU_NAMES[@]}"; do
                if [ "$zone_name" == "$gpu_name" ]; then
                    # GPU 온도는 일반적으로 temp1_input에 있습니다.
                    TEMP_FILE=$(ls "$hwmon_dir"/temp*_input | head -n 1)
                    
                    if [ -f "$TEMP_FILE" ]; then
                        temp_milli=$(cat "$TEMP_FILE")
                        TEMP_VAL=$((temp_milli / 1000))
                        FOUND=true
                        break 2 # 내부/외부 루프 모두 빠져나옴
                    fi
                fi
            done
        fi
    done

    if [ "$FOUND" = false ]; then
        # 실패 시 "fail" 대신 0을 출력하거나 아무것도 출력하지 않음
        echo "0" 
    fi

    # Eww로 온도 값 출력
    echo "$TEMP_VAL"

    # 1초 대기
    sleep 1
done
