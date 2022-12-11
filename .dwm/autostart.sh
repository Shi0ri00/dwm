#!/bin/bash

feh --randomize --bg-fill ~/wallpapers &

picom --experimental-backends --config ~/scripts/config/picom.conf &

fcitx5 &

/bin/bash ~/scripts/dwm_refresh.sh &

~/scripts/autostart_wait.sh

