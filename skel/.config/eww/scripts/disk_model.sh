#!/usr/bin/env bash

# 루트 파티션의 소스 장치 경로를 찾습니다 (예: /dev/nvme0n1p2)
ROOT_DEV=$(findmnt -n -o SOURCE -T / | sed 's/\[.*\]//')

if [ -z "$ROOT_DEV" ]; then
    echo "오류: 루트 장치를 찾을 수 없습니다."
    exit 1
fi

# 장치의 상위 디스크 이름(PKNAME)을 가져옵니다 (예: nvme0n1)
DISK_NAME=$(lsblk -n -o PKNAME "$ROOT_DEV" | tail -n 1)

if [ -z "$DISK_NAME" ]; then
    echo "상위 디스크 이름을 찾을 수 없습니다."
    exit 1
fi

# udevadm을 사용하여 MODEL 정보를 조회합니다.
# /dev/nvme0n1 경로의 정보를 쿼리합니다.
MODEL_INFO=$(udevadm info --query=property --name="/dev/$DISK_NAME" | grep 'ID_MODEL=')

# 결과 출력 (ID_MODEL=SAMSUNG_SSD_980 같은 형식으로 출력됩니다)
if [ -z "$MODEL_INFO" ]; then
    echo "udevadm으로 모델 정보를 찾을 수 없습니다."
else
    # ID_MODEL= 부분만 제거하고 순수 모델명만 출력
    echo "$MODEL_INFO" | cut -d'=' -f2
fi
