startup () {
    if [[ "$music" == "on" ]]; then
        play -v 0.5 -q audio/bgm.mp3 &
    fi

    #================Level===============#
    # Define platforms
    platformX=( 0 10 30 38 60)
    platformY=(10 13 17 10  9)
    platformW=( 9 15  9  9  9)
    platformH=( 1  1  1  1  1)
    platformI=(02 00 00 00 01)

    # Set player start position
    posX=5
    posY=18
    #====================================#

    # Set player "sprites"
    charcolor="\e[38;2;160;160;255m"
    character=≣
    characterdefault=≣
    charactercrouch=🬋

    # Set other "sprites"
    coin=₪
    number=(🯰 🯱 🯲 🯳 🯴 🯵 🯶 🯷 🯸 🯹)

    velX=0
    velY=0
    win=0

    fps=$(awk "BEGIN {print 1/$fps}")
}

stage () {
    tput home
    echo -e "
\e[A▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█  \e[94mLVL${number[1]} \e[0m █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▌                                                                              ▐
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"

}

platforms () {
    loop=0
    for value in "${platformX[@]}"; do
        loops=0
        case ${platformI[$loop]} in
        00) # Standard platform
            tput cup ${platformY[$loop]} $((platformX[$loop]))
            echo -en "\e[30;1m🭒"
            while [[ $loops -lt $((platformW[$loop] - 2)) ]]; do
                echo -en "█"
                loops=$((loops + 1))
            done
            echo -en "🭝"
            ;;
        01) # Goal platform
            tput cup ${platformY[$loop]} $((platformX[$loop]))
            echo -en "\e[33;1m🭒"
            while [[ $loops -lt $((platformW[$loop] - 2)) ]]; do
                echo -en "🬗"
                loops=$((loops + 1))
            done
            echo -en "🭝"
            ;;
        02) # Left wall platform
            tput cup ${platformY[$loop]} $((platformX[$loop]))
            echo -en "\e[30;1m█"
            while [[ $loops -lt $((platformW[$loop] - 2)) ]]; do
                echo -en "█"
                loops=$((loops + 1))
            done
            echo -en "🭝"
            ;;
        03) # Left wall platform
            tput cup ${platformY[$loop]} $((platformX[$loop]))
            echo -en "\e[30;1m🭒"
            while [[ $loops -lt $((platformW[$loop] - 2)) ]]; do
                echo -en "█"
                loops=$((loops + 1))
            done
            echo -en "█"
            ;;
        esac
        loop=$((loop + 1))
    done
}

input () {
    read -rsN2 -t 0.0001 input # Listen for keypress, this is SUPER HACKY LOL
    length=${#input}
    loop=1
    while [[ $loop -le $length ]]; do
        inputf=$(echo $input | cut -c$loop-$loop)
        if [[ "$inputf" = "w" ]] && [[ $velY -eq 0 ]] && [[ $(collideY) -eq 1 ]]; then
            velY=$((velY-7))
        fi

        if [[ $velX -lt 5 ]] && [[ $velX -gt -5 ]]; then
            if [[ "$inputf" = "d" ]]; then
                velX=$((velX+2))
            fi

            if [[ "$inputf" = "a" ]]; then
                velX=$((velX-2))
            fi
        fi
        if [[ "$inputf" = "s" ]]; then
            down=1
        else
            down=0
        fi
        loop=$((loop + 1))
    done
    read -t 0.0001 -n 10000 discard # Discard any saved keypresses when the input function ends
}

info () {
    tput cup 20 0
    echo -e "\n\e[34m
╭────────────╦────────────╮
╽            ┋            ╽
╿            ┋            ╿
╰────────────╩────────────╯
"
    tput cup 23 2
    echo -ne "X Vel: $velX"
    tput cup 23 15
    echo -ne "X Pos: $posX"
    tput cup 24 2
    echo -ne "Y Vel: $((-velY))"
    tput cup 24 15
    echo -ne "Y Pos: $((posY)) \e[0m"
}

textbox () {
    tput sc
    loop=0
    str=$(echo "${3%%\\*}")
    strlen=${#str}
    box=$(($2 - (strlen/2) - 2))
    boy=$(($1 - 1))
    midln=""
    midspc=""
    while [[ $loop -le $((strlen + 1)) ]]; do
        midln+="─"
        midspc+=" "
        loop=$((loop + 1))
    done
    loop=0
    tput cup $boy $box && echo -en "╭$midln╮"
    while [[ $loop -le $(($(echo "$3" | grep -o "\n" | wc -l) - 1)) ]]; do
        tput cup $((boy + loop + 1)) $box && echo -en "│$midspc│"
        loop=$((loop + 1))
    done
    tput cup $((boy + 1)) $((box + 2)) && echo -en $3
    tput cup $((boy + loop + 1)) $box && echo -en "╰$midln╯"
    tput rc
}

movecalc () {
    # These are the left and right walls, do not allow the player to go past them
    if [[ $posX -le 1 ]]; then
        velX=0
        posX=1
    elif [[ $posX -ge 78 ]]; then
        velX=0
        posX=78
    fi

    # If no collision, make player fall faster every other frame
    if ! [[ $(collideY) -eq 1 ]] && [[ $((counter%2)) -eq 1 ]]; then
        velY=$((velY+1))
    fi

    # Slow the X veolocity if colliding.
    if [[ $(collideY) -eq 1 ]]; then
        if [[ $velX -gt 0 ]]; then
            velX=$((velX - 2))
        fi
        if [[ $velX -lt 0 ]]; then
            velX=$((velX + 2))
        fi
    fi

    if [[ $counter -lt 64 ]]; then
        counter=$((counter + 1))
    else
        counter=0
    fi
}

move () {
    loop=0
    while [[ $loop -le ${velX#-} ]] && ! [[ $posX -le 0 ]]; do
        if [[ $velX -lt 0 ]]; then
            posX=$((posX - 1))
        elif [[ $velX -gt 0 ]]; then
            posX=$((posX + 1))
        fi

        loop=$((loop + 1))
    done

    loop=0
    while [[ $loop -le ${velY#-} ]]; do
        if [[ $velY -lt 0 ]]; then
            posY=$((posY - 1))
            velY=$((velY + 1))
        elif [[ $velY -gt 0 ]]; then
            posY=$((posY + 1))
        fi

        if [[ $(collideY) -eq 1 ]]; then
            velY=0
        fi

        loop=$((loop + 1))
    done
}

collideY () {
    loop=0
    for value in "${platformY[@]}"; do
        if [[ $((platformY[$loop] - (posY + 1))) -eq 0 ]] && [[ $((platformX[$loop] + platformW[$loop])) -gt $posX ]] && [[ ${platformX[$loop]} -le $posX ]]; then
            echo 1
            break
        fi
        loop=$((loop + 1))
    done

    if [[ $posY -ge 20 ]]; then
        echo 1
    fi
}

animate () {
    if [[ $down -gt 0 ]]; then
        character=$charactercrouch
    else
        character=$characterdefault
    fi

}

char () {
    tput cup $posY $((posX - 1)) && echo ""
    tput cup $posY $posX && echo -e "${charcolor}${character}\e[0m"
    tput cup $posY $((posX + 1)) && echo ""
}

render () {
    clear
    stage # Draw the stage behind the player
    platforms # Draw the platforms using the position arrays
    animate
    char # Print the player using the calculated positions
}
