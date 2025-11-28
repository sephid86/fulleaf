#!/usr/bin/env bash
# ~/.config/eww/scripts/get_cpu_model.sh

# 이 명령어가 Linux 시스템에서 CPU 모델명을 가져옵니다.
grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//'
