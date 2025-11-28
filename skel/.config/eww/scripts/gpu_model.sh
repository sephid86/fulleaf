#!/usr/bin/env bash
# lspci를 사용하여 GPU 모델명 중 괄호 안의 내용만 추출합니다.

MODEL_INFO=$(lspci | grep "VGA" | cut -d ":" -f3 | sed 's/^[ \t]*//')

# 정규 표현식을 사용하여 괄호 안의 내용만 추출합니다.
# -o 옵션은 매칭되는 부분만 출력합니다.
# -P 옵션은 펄(Perl) 호환 정규 표현식을 활성화합니다.
# \( 와 \) 는 괄호 자체를 찾기 위한 이스케이프 문자입니다.
# .*? 는 최소한의 문자열 매칭을 의미합니다.
# ID_INSIDE_BRACKETS=$(echo "$MODEL_INFO" | grep -oP '\[.*?\]')
ID_INSIDE_BRACKETS=$(echo "$MODEL_INFO" | grep -oP '\[\K.*?(?=\])')

if [ -z "$ID_INSIDE_BRACKETS" ]; then
    echo "[Not Found]"
else
    # 결과에 이미 대괄호가 포함되어 있습니다.
    echo "$ID_INSIDE_BRACKETS" 
fi
