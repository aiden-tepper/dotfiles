#!/bin/bash

# Define wallpaper paths
SUNRISE="/home/aiden/.config/hypr/wallpapers/macos/bigsur/sunrise"
MORNING="/home/aiden/.config/hypr/wallpapers/macos/bigsur/morning"
AFTERNOON="/home/aiden/.config/hypr/wallpapers/macos/bigsur/afternoon"
SUNSET="/home/aiden/.config/hypr/wallpapers/macos/bigsur/sunset"
NIGHT="/home/aiden/.config/hypr/wallpapers/macos/bigsur/night"

# Set wallpaper based on argument
case $1 in
	sunrise)
		swww img -t any --transition-duration 10 --transition-fps 60 $SUNRISE
		;;
	morning)
		swww img -t any --transition-duration 10 --transition-fps 60 $MORNING
		;;
	afternoon)
		swww img -t any --transition-duration 10 --transition-fps 60 $AFTERNOON
		;;
	sunset)
		swww img -t any --transition-duration 10 --transition-fps 60 $SUNSET
		;;
	night)
		swww img -t any --transition-duration 10 --transition-fps 60 $NIGHT
		;;
	*)
		echo "Invalid time of day"
		exit 1
		;;
esac
