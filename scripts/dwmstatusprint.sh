#!/bin/bash

function get_bytes {
	interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
	line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
	eval $line
	now=$(date +%s%N)
}

function get_velocity {
	value=$1
	old_value=$2
	now=$3

	timediff=$(($now - $old_time))
	velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
	if test "$velKB" -gt 1024
	then
		echo $(echo "$velKB/1024" | bc)MB/s
	else
		echo ${velKB}KB/s
	fi
}

get_bytes
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

get_load()
{
	local PREFIX=' '
	# Get the first line with aggregate of all CPUs
	cpu_last=($(head -n1 /proc/stat))
	cpu_last_sum="${cpu_last[@]:1}"
	cpu_last_sum=$((${cpu_last_sum// /+}))

	sleep 0.05

	cpu_now=($(head -n1 /proc/stat))
	cpu_sum="${cpu_now[@]:1}"
	cpu_sum=$((${cpu_sum// /+}))

	cpu_delta=$((cpu_sum - cpu_last_sum))
	cpu_idle=$((cpu_now[4]- cpu_last[4]))
	cpu_used=$((cpu_delta - cpu_idle))
	cpu_usage=$((100 * cpu_used / cpu_delta))
	# Keep this as last for our next read
	cpu_last=("${cpu_now[@]}")
	cpu_last_sum=$cpu_sum

	#echo "$PREFIX$cpu_usage%"
	printf "$PREFIX$cpu_usage"
}

PREFIX=' '

get_disk()
{
    TOTAL_SIZE=$( df -h / | tail -1 | awk {'printf $2'})
    USED_SIZE=$(df -h / | tail -1 | awk {'printf $3'})
    PERCENTAGE=$(df -h / | tail -1 | awk {'printf $5'})

    echo "$PREFIX$USED_SIZE($PERCENTAGE)"
}

print_date(){
	date '+%Y-%m-%d %l:%M %p'
}

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
	echo -e "$memfree"
}

dwm_weather() {
        printf "摒 %s" "$(curl -s wttr.in/Harbin?format=1 | grep -o "[-0-9].*")"
}

dwm_alsa () {
    VOL=$(amixer -M get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
	VOLSTAT=$(amixer -M get Master | tail -n1 | sed -r "s/.*\[(.*)%\] \[(.*)\]/\2/")
    printf "%s" "$SEP1"
    if [ "$VOLSTAT" = "off" ]; then
        printf "ﱝ"
    else
        printf "墳: %s%%" "$VOL"
    fi
    printf "%s\n" "$SEP2"
}

get_bytes
vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

xsetroot -name "| $(get_load)% |  $(print_mem)M | $(get_disk) | ↓$vel_recv ↑$vel_trans | $(dwm_alsa) | $(dwm_weather) | $(print_date) |"

exit 0
