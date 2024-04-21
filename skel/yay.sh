#!/bin/bash
AUTO_DIR=$(pwd)
#yay 를 설치해줍니다.
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo -e "
\033[01;32m 
-- yay 설치가 완료되었습니다. -- 
\033[00m
"

