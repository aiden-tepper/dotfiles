#!/bin/bash

# Define wallpaper paths
SUNRISE="/home/aiden/.config/hypr/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers/Surface/Surface01.jpg"
MORNING="/home/aiden/.config/hypr/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers/Surface/Surface02.jpg"
AFTERNOON="/home/aiden/.config/hypr/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers/Surface/Surface04.jpg"
SUNSET="/home/aiden/.config/hypr/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers/Surface/Surface05.jpg"
NIGHT="/home/aiden/.config/hypr/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers/Surface/Surface06.jpg"

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
