#!/usr/bin/env bash

function setbg {
	cp $1 ~/.config/i3/wallpaper.jpg
	DISPLAY=:0.0 feh --bg-scale ~/.config/i3/wallpaper.jpg
#	notify-send "wallpaper changed"
}

hour=$(date +%H)
time_of_day=$(sunwait poll 43.08N 89.40W)
[[ $time_of_day == "DAY" ]] && [ $hour -lt 12 ] && setbg $1
[ $hour -gt 11 ] && [ $hour -lt 15 ] && setbg $2
[ $hour -gt 14 ] && [[ $time_of_day == "DAY" ]] && setbg $3
[[ $time_of_day == "NIGHT" ]] && setbg $4
