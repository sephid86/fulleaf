#!/usr/bin/env bash

# 이전 CPU 사용량 통계를 저장할 파일
EWWDATAPATH="$HOME/.config/eww/cpu_usage_data"

# 초기 통계 파일이 없으면 생성
if [ ! -f "$EWWDATAPATH" ]; then
    # 첫 실행 시 통계 저장 (초기화)
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    current_idle=$((idle + iowait))
    current_total=$((user + nice + system + current_idle + irq + softirq + steal))
    echo "$current_idle $current_total" > "$EWWDATAPATH"
    sleep 1
fi


# 무한 루프 시작 - 이 스크립트는 종료되지 않습니다.
while true; do
    # /proc/stat에서 현재 CPU 총 사용 시간과 유휴 시간을 읽어옵니다.
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    current_idle=$((idle + iowait))
    current_total=$((user + nice + system + current_idle + irq + softirq + steal))

    # 이전에 저장된 통계 불러오기
    read -r prev_idle prev_total < "$EWWDATAPATH"

    # CPU 사용률 계산
    diff_idle=$((current_idle - prev_idle))
    diff_total=$((current_total - prev_total))
    
    usage=0
    if [ "$diff_total" -gt 0 ]; then
        usage=$((100 * (diff_total - diff_idle) / diff_total))
    fi
    
    # 현재 통계 저장 (다음 루프를 위해)
    echo "$current_idle $current_total" > "$EWWDATAPATH"
    
    # Eww로 현재 사용률(퍼센트)만 출력
    # deflisten은 한 줄의 텍스트를 변수 값으로 그대로 받습니다.
    echo "$usage"

    # 1초 대기
    sleep 1
done
