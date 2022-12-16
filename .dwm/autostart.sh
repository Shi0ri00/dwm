#!/bin/bash

/bin/bash ~/scripts/dwm_refresh.sh &

/bin/bash ~/scripts/feh.sh &

picom -b --experimental-backends --config ~/scripts/config/picom.conf

flameshot &

fcitx5 &

dunst &

~/scripts/autostart_wait.sh &
