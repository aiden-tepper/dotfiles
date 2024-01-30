#!/bin/bash

# Define change_wallpaper script location
SET_WALLPAPER="/home/aiden/.config/hypr/change_wallpaper.sh"

# Get current hour
HOUR=$(date +%H)

# Set wallpaper based on current hour
if [ $HOUR -ge 5 -a $HOUR -lt 9 ]; then
	$SET_WALLPAPER sunrise
elif [ $HOUR -ge 9 -a $HOUR -lt 13 ]; then
	$SET_WALLPAPER morning
elif [ $HOUR -ge 13 -a $HOUR -lt 17 ]; then
	$SET_WALLPAPER afternoon
elif [ $HOUR -ge 17 -a $HOUR -lt 21 ]; then
	$SET_WALLPAPER sunset
else
	$SET_WALLPAPER night
fi
