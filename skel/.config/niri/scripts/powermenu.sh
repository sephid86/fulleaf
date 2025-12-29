#!/usr/bin/env bash
# https://gist.github.com/mxdevmanuel/a2229d427b39a9e40f2198979caa40c1

op=$( echo -e " Poweroff\n Reboot\n WinBoot\n BiosBoot\n Suspend\n Lock\n Logout" | wofi -i --dmenu | awk '{print tolower($2)}' )

case $op in 
  poweroff)
    ;&
  reboot)
    ;&
  suspend)
    systemctl $op
    ;;
  lock)
    swaylock
    ;;
  logout)
    systemctl --user exit && hyprctl dispatch exit
    ;;
  biosboot)
    systemctl reboot --firmware-setup
    ;;
  winboot)
    systemctl reboot --boot-loader-entry=auto-windows
    ;;
esac
