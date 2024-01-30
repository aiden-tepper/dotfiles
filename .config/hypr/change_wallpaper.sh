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
		swww img $SUNRISE
		;;
	morning)
		swww img $MORNING
		;;
	afternoon)
		swww img $AFTERNOON
		;;
	sunset)
		swww img $SUNSET
		;;
	night)
		swww img $NIGHT
		;;
	*)
		echo "Invalid time of day"
		exit 1
		;;
esac
