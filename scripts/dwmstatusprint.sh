#!/bin/bash

function get_bytes {
	# Find active network interface
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

check_connect(){
	interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
	line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
	sped=$(echo $line | sed -r "s/.*=(.*).*/\1/")
	if ["$sped" -eq 0]; then
		printf "Nointernet"
	else 
		printf "Internet"
	fi
}

print_date(){
	date '+%Y-%m-%d %H:%M:%S'
}

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
	echo -e "$memfree"
}

dwm_alsa () {
    VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
	VOLSTAT=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\] \[(.*)\]/\2/")
    printf "%s" "$SEP1"
    if [ "$VOL" -eq 0 ] || [ "$VOLSTAT" = "off" ]; then
        printf "Mute"
    else
        printf "VOL: %s%%" "$VOL"
    fi
    printf "%s\n" "$SEP2"
}

get_bytes
vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

xsetroot -name "|$(print_mem)M FREE| $(check_connect) ↓$vel_recv ↑$vel_trans | $(dwm_alsa) | $(print_date) |"

exit 0
