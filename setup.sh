#!/usr/bin/env bash
#
# @file setup.sh
# @brief ...

display_options() {
    local selected_index=$1
    local options=("${@:2}")           
    local total_options=${#options[@]}

    for ((i=0; i<total_options; i++)); do 
        if [[ $i -eq $selected_index ]]; then
            echo -ne "\e[7m${options[$i]}\e[0m "
        else
            echo -n "${options[$i]} "
        fi
    done
}

select_option() {
    local selected_index=0
    local options=("$@")           
    local total_options=${#options[@]}

    echo -ne "\e[?25l"

    while true; do
        display_options "$selected_index" "${options[@]}"

        read -rsn1 input 
        case $input in 
            h|H|k|K) ((selected_index--));;
            j|J|l|L) ((selected_index++));;
            '') break;;
        esac

        if ((selected_index<0)); then
            selected_index=$((total_options - 1))
        elif ((selected_index>=total_options)); then
            selected_index=0
        fi

        echo -ne "\r\e[K"      
    done
    
    echo -ne "\e[?25h";

    echo -e "\n"

    selected_option="${options[selected_index]}"
}

set_option() {
    local key=$1
    local value=$2
    echo "${key}=\"${value}\"" >> setup.conf
}

echo -e "\n$(lsblk)\n"

echo "Select disk to install to:"
options=($(lsblk --nodeps --output NAME,TYPE | awk '$2 == "disk" {print "/dev/" $1}'))
select_option "${options[@]}"
set_option "DISK" "$selected_option"

echo -n "Desired hostname for the installed system: "; read -r hostname; echo
set_option "HOSTNAME" "$hostname"

echo -n "Enter root password: "; read -rs root_password; echo
set_option "ROOT_PASSWORD" "$root_password"

echo -n "Enter username: "; read -r username
set_option "USERNAME" "$username"

echo -n "Enter user password: "; read -rs user_password; echo
set_option "USER_PASSWORD" "$user_password"

echo -e "\n"
