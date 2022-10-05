#!/bin/bash

stty -echo # Disable keyboard output

source options.cfg # Grab configs
source functions.sh

startup

while true; do
    input       #read keyboard input

    move        #move the character

    movecalc    #update movement parameters

    render      #render the player, stage, and platforms

    #info        #display the velocity and position information

    tput cup 21 80
    if [[ "$input" = "q" ]] || [[ $win -gt 0 ]]; then
        stty echo
        tput cup 22 0
        textbox 10 39 "Exiting Game"
        kill %1 &> /dev/null
        exit 0
    fi

    sleep $fps
done
