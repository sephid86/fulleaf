#!/usr/bin/env bash

# ~/.config/eww/scripts/gpu_fanspeed.sh

# GPU 이름 목록 (AMD 사용 시 'amdgpu', NVIDIA 오픈 소스 사용 시 'nouveau' 등을 시도해 보세요)
GPU_NAMES=("amdgpu" "nouveau" "radeon")

# 이 스크립트는 'deflisten'으로 사용되므로 무한 루프가 필요합니다.
while true; do
    FANSPEED_VAL="0"
    FOUND=false

    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon_dir/name" ]; then
            zone_name=$(cat "$hwmon_dir/name")

            for gpu_name in "${GPU_NAMES[@]}"; do
                if [ "$zone_name" == "$gpu_name" ]; then
                    # 팬 속도는 일반적으로 fan1_input 또는 fan*_input에 있습니다.
                    FAN_FILE=$(ls "$hwmon_dir"/fan*_input | head -n 1)
                    
                    if [ -f "$FAN_FILE" ]; then
                        FANSPEED_VAL=$(cat "$FAN_FILE") # RPM 값은 1000으로 나누지 않음
                        FOUND=true
                        break 2 # 내부/외부 루프 모두 빠져나옴
                    fi
                fi
            done
        fi
    done

    if [ "$FOUND" = false ]; then
        # 실패 시 "0"을 출력
        echo "0" 
    fi

    # Eww로 팬 속도 값 출력
    echo "$FANSPEED_VAL"

    # 1초 대기
    sleep 1
done
