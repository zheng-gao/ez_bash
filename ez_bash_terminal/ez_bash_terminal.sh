#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
[[ -z "${EZ_BASH_HOME}" ]] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1


###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_clean_oneline() {
    tput cuu1 #Move cursor up by one line
    tput el #Clear the line
}

function ez_set_terminal_title() {
    ez_set_argument --short "-t" --long "--title" --type "String" --required --default "hostname" --info "Terminal Title" || return 1
    [[ ! -z "${@}" ]] && ez_ask_for_help "${@}" && ez_function_help && return
    local title; title="$(ez_get_argument --short "-t" --long "--title" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ "${title}" == "hostname" ]]; then title=$(hostname); fi
    echo -n -e "\033]0;${title}\007"
}

function ez_sleep() {
    ez_set_argument --short "-u" --long "--unit" --required --default "Second" --choices "d" "D" "Day" "h" "H" "Hour" "m" "M" "Minute" "s" "S" "Second" --info "Unit Name"&&
    ez_set_argument --short "-v" --long "--value" --required --info "Number of units to sleep" &&
    ez_set_argument --short "-n" --long "--interval" --required --default 1 --info "Output refresh frequency in seconds, 0 for no output" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local unit; unit="$(ez_get_argument --short "-u" --long "--unit" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local value; value="$(ez_get_argument --short "-v" --long "--value" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local interval; interval="$(ez_get_argument --short "-n" --long "--interval" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [ "${interval}" -lt 0 ] && interval=1
    local timeout_in_seconds=0
    case "${unit}" in
        "d" | "D" | "Day") timeout_in_seconds="$((${value} * 86400))" ;;
        "h" | "H" | "Hour") timeout_in_seconds="$(("${value}" * 3600))" ;;
        "m" | "M" | "Minute") timeout_in_seconds="$(("${value}" * 60))" ;;
        *) timeout_in_seconds=${value} ;;
    esac
    if [ "${interval}" -eq 0 ]; then sleep "${timeout_in_seconds}" && return; fi
    local wait_seconds=0
    local timeout_string=$(ez_get_readable_time_from_seconds -s "${timeout_in_seconds}" -f "Mini")
    local wait_seconds_string=$(ez_get_readable_time_from_seconds -s "${wait_seconds}" -f "Mini")
    ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
    while [ "${wait_seconds}" -lt "${timeout_in_seconds}" ]; do
        local seconds_left=$((timeout_in_seconds - wait_seconds))
        if [ "${seconds_left}" -ge "${interval}" ]; then
            ((wait_seconds += "${interval}"))
            sleep "${interval}"
            ez_clean_oneline
            wait_seconds_string=$(ez_get_readable_time_from_seconds -s "${wait_seconds}" -f "Mini")
            ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
        else
            wait_seconds="${timeout_in_seconds}"
            sleep "${seconds_left}"
            ez_clean_oneline
            wait_seconds_string=$(ez_get_readable_time_from_seconds -s "${wait_seconds}" -f "Mini")
            ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
        fi
    done
}

function ez_print_progress() {
    ez_set_argument --short "-f" --long "--filler" --required --default ">" --info "Symbol for progress bar filler" &&
    ez_set_argument --short "-b" --long "--blank" --required --default " " --info "Symbol for progress bar blanks" &&
    ez_set_argument --short "-t" --long "--total" --required --info "Total Steps" &&
    ez_set_argument --short "-c" --long "--current" --required --info "Current Step" &&
    ez_set_argument --short "-d" --long "--delete" --required --default 1 --info "Delete lines to hold the progress bar" &&
    ez_set_argument --short "-p" --long "--percentage" --type "Flag" --info "Show Percentage" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local filler_symbol; filler_symbol="$(ez_get_argument --short "-f" --long "--filler" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local blank_symbol; blank_symbol="$(ez_get_argument --short "-b" --long "--blank" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local total_steps; total_steps="$(ez_get_argument --short "-t" --long "--total" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local current_step; current_step="$(ez_get_argument --short "-c" --long "--current" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local show_percentage; show_percentage="$(ez_get_argument --short "-p" --long "--percentage" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local delete_lines; delete_lines="$(ez_get_argument --short "-d" --long "--delete" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [ "${delete_lines}" -lt 1 ] && ez_print_log -l "ERROR" -m "Invalid value \"${delete_lines}\" for \"-d|--delete\"" && return 1
    [ "${current_step}" -lt 0 ] && ez_print_log -l "ERROR" -m "Invalid value \"${current_step}\" for \"-c|--current\"" && return 1
    [ "${total_steps}" -le 0 ] && ez_print_log -l "ERROR" -m "Invalid value \"${total_steps}\" for \"-t|--total\"" && return 1
    [ "${total_steps}" -lt "${current_step}" ] && ez_print_log -l "ERROR" -m "\"-t|--total\" ${total_steps} less than \"-c|--current\" ${current_step}" && return 1
    local terminal_length="$(tput cols)"
    local percentage_string=""
    local integer_part=0
    if [ "${show_percentage}" = "${EZ_BASH_BOOL_TRUE}" ]; then
        local percentage="$((${current_step} * 10000 / ${total_steps}))"
        percentage_string="[  0.00%]"
        local decimal_part=0
        if [ "${percentage}" -gt 0 ]; then
            integer_part="$((${percentage} / 100))"
            decimal_part="$((${percentage} % 100))"
            if [ "${integer_part}" -lt 10 ]; then
                percentage_string="[  ${integer_part}"
            elif [ "${integer_part}" -eq 100 ]; then
                percentage_string="[${integer_part}"
            else
                percentage_string="[ ${integer_part}"
            fi
            [ "${decimal_part}" -lt 10 ] && percentage_string+=".0${decimal_part}%]" || percentage_string+=".${decimal_part}%]"
        fi
        
    else
        local length_diff="$((${#total_steps} - ${#current_step}))"
        local percentage_string="["
        for ((i=0; i < "${length_diff}"; ++i)); do percentage_string+=" "; done
        percentage_string+="${current_step}/${total_steps}]"
        integer_part="$((${current_step} * 100 / ${total_steps}))"
    fi
    local progress_bar_length="$((${terminal_length} - ${#percentage_string} - 2))"
    local filler_count="$((${progress_bar_length} * ${integer_part} / 100))"
    local blank_count="$((${progress_bar_length} - ${filler_count}))"
    local progress_bar_string=""
    for ((i=0; i < "${filler_count}"; ++i)); do progress_bar_string+="${filler_symbol}"; done
    for ((i=0; i < "${blank_count}"; ++i)); do progress_bar_string+="${blank_symbol}"; done
    [ "${current_step}" -gt 0 ] && for ((i=0; i < "${delete_lines}"; ++i)); do ez_clean_oneline; done
    echo "${percentage_string}[${progress_bar_string}]"
}