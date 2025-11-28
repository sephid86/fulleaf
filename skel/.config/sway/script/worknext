#!/bin/sh

current_workspace=$(swaymsg -p -t get_workspaces|grep focused|grep -o "[0-9]")

if [ "$1" = "window" ]; then
	category="swaymsg move window to workspace"
	shift
else
	category="swaymsg workspace number"
fi

if [ "$1" = "next" ]; then
	test $current_workspace -eq 4 && exit 1
	$category $((current_workspace + 1))
elif [ "$1" = "prev" ]; then
	test $current_workspace -eq 1 && exit 1
	$category $((current_workspace - 1))
fi
