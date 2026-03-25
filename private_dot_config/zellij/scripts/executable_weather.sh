#!/bin/bash

loc=$(curl -s ipinfo.io | jq '.loc' | sed 's/"//g')

lat=$(echo $loc | cut -d',' -f1)
long=$(echo $loc | cut -d',' -f2)

weather=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude="$lat"&longitude="$long"&current=temperature,weathercode,is_day&temperature_unit=fahrenheit")

temp=$(echo $weather | jq '.current.temperature')
rounded_temp=$(printf '%.*f\n' 0 $temp)
wea=$(echo $weather | jq '.current.weathercode')
is_day=$(echo $weather | jq '.current.is_day')

clear=("0" "1")
partly_cloudy=("2")
overcast=("3")
fog=("45" "48")
drizzle=("51" "53" "55" "56" "57")
rain=("61" "63" "65" "66" "67", "80", "81", "82")
snow=("71" "73" "75" "77" "85" "86")
thunderstorm=("95" "96" "99")

if [[ ${clear[@]} =~ $wea ]]; then
	if [[ 1 =~ $is_day ]]; then
		icon=
	else
		icon=
	fi
elif [[ ${partly_cloudy[@]} =~ $wea ]]; then
	if [[ 1 =~ $is_day ]]; then
		icon=
	else
		icon=
	fi
elif [[ ${overcast[@]} =~ $wea ]]; then
	icon=󰖐
elif [[ ${fog[@]} =~ $wea ]]; then
	icon=󰖑
elif [[ ${drizzle[@]} =~ $wea ]]; then
	icon=
elif [[ ${rain[@]} =~ $wea ]]; then
	icon=
elif [[ ${snow[@]} =~ $wea ]]; then
	icon=󰜗
elif [[ ${thunderstorm[@]} =~ $wea ]]; then
	icon=
fi

echo $icon $rounded_temp°
