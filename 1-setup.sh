#!/usr/bin/env bash

display_options() {
    local selected_index="$1"
    local options=("${@:2}")
    local total_options="${#options[@]}"

    for ((i = 0; i < total_options; i++)); do
        if [[ "$i" -eq "$selected_index" ]]; then
            echo -ne "\e[7m${options[$i]}\e[0m "
        else
            echo -n "${options[$i]} "
        fi
    done
}

select_option() {
    local selected_index=0
    local options=("$@")
    local total_options="${#options[@]}"

    echo -ne "\e[?25l"

    while true; do
        display_options "$selected_index" "${options[@]}"

        read -rsn1 input
        case "$input" in
            h|H|k|K) ((selected_index--));;
            j|J|l|L) ((selected_index++));;
            '') break;;
        esac

        ((selected_index = (selected_index + total_options) % total_options))

        echo -ne "\r\e[K"
    done

    echo -ne "\e[?25h";
    echo -e "\n"

    selected_option="${options[selected_index]}"
}

set_option() {
    local key="$1"
    local value="$2"
    echo "${key}=\"${value}\"" >> setup.conf
}

handle_error() {
    local message="$1"
    echo "Error: $message" >&2
    exit 1
}

echo -e "\n$(lsblk)\n"

echo "Select disk to install to:"
options=($(lsblk --nodeps --output NAME,TYPE | awk '$2 == "disk" {print "/dev/" $1}'))
[[ "${#options[@]}" -eq 0 ]] && handle_error "No disks available for installation."
select_option "${options[@]}"
set_option "DISK" "$selected_option"

read -rp "Desired hostname for the installed system: " hostname; echo
set_option "HOSTNAME" "$hostname"

read -rsp "Enter root password: " root_password; echo
set_option "ROOT_PASSWORD" "$root_password"

read -rp "Enter username: " username
set_option "USERNAME" "$username"

read -rsp "Enter user password: " user_password; echo
set_option "USER_PASSWORD" "$user_password"

echo -e "\n"