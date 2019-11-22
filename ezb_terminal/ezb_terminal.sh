function ezb_clear() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-l" --long "--lines" --required --default "0" \
                    --info "Lines to clean, non-positve clear console" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local lines && lines="$(ezb_arg_get --short "-l" --long "--lines" --arguments "${@}")" || return 1
    if [[ "${lines}" -gt 0 ]]; then
        local i=0; for ((; i < "${lines}"; ++i)); do tput cuu1 && tput el; done # cursor up one line and clean
    else
        clear
    fi
}

function ezb_terminal_set_title() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-t" --long "--title" --type "String" --required --default "hostname" \
                    --info "Terminal Title" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local title && title="$(ezb_arg_get --short "-t" --long "--title" --arguments "${@}")" || return 1
    if [[ "${title}" == "hostname" ]]; then title=$(hostname); fi
    echo -n -e "\033]0;${title}\007"
}

function ezb_sleep() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-u" --long "--unit" --required --default "Second" \
                    --choices "d" "D" "Day" "h" "H" "Hour" "m" "M" "Minute" "s" "S" "Second" --info "Unit Name" &&
        ezb_arg_set --short "-v" --long "--value" --required --info "Number of units to sleep" &&
        ezb_arg_set --short "-n" --long "--interval" --required --default 1 \
                    --info "Output refresh frequency in seconds, 0 for no output" || return 1
    fi
    ezb_function_usage "${@}" && return
    local unit && unit="$(ezb_arg_get --short "-u" --long "--unit" --arguments "${@}")" &&
    local value && value="$(ezb_arg_get --short "-v" --long "--value" --arguments "${@}")" &&
    local interval && interval="$(ezb_arg_get --short "-n" --long "--interval" --arguments "${@}")" || return 1
    if [[ "${interval}" -lt 0 ]]; then interval=1; fi
    local timeout_in_seconds=0
    case "${unit}" in
        "d" | "D" | "Day") timeout_in_seconds="$((${value} * 86400))" ;;
        "h" | "H" | "Hour") timeout_in_seconds="$(("${value}" * 3600))" ;;
        "m" | "M" | "Minute") timeout_in_seconds="$(("${value}" * 60))" ;;
        *) timeout_in_seconds=${value} ;;
    esac
    if [[ "${interval}" -eq 0 ]]; then sleep "${timeout_in_seconds}" && return; fi
    local wait_seconds=0
    local timeout_string=$(ezb_time_seconds_to_readable -s "${timeout_in_seconds}" -f "Mini")
    local wait_seconds_string=$(ezb_time_seconds_to_readable -s "${wait_seconds}" -f "Mini")
    ezb_log_info "Sleeping... (${wait_seconds_string} / ${timeout_string})"
    while [[ "${wait_seconds}" -lt "${timeout_in_seconds}" ]]; do
        local seconds_left=$((timeout_in_seconds - wait_seconds))
        if [[ "${seconds_left}" -ge "${interval}" ]]; then
            ((wait_seconds += "${interval}"))
            sleep "${interval}"
            ezb_clear --lines 1
            wait_seconds_string=$(ezb_time_seconds_to_readable -s "${wait_seconds}" -f "Mini")
            ezb_log_info "Sleeping... (${wait_seconds_string} / ${timeout_string})"
        else
            wait_seconds="${timeout_in_seconds}"
            sleep "${seconds_left}"
            ezb_clear --lines 1
            wait_seconds_string=$(ezb_time_seconds_to_readable -s "${wait_seconds}" -f "Mini")
            ezb_log_info "Sleeping... (${wait_seconds_string} / ${timeout_string})"
        fi
    done
}

function ezb_print_progress() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-f" --long "--filler" --required --default ">" --info "Symbol for progress bar filler" &&
        ezb_arg_set --short "-b" --long "--blank" --required --default " " --info "Symbol for progress bar blanks" &&
        ezb_arg_set --short "-t" --long "--total" --required --info "Total Steps" &&
        ezb_arg_set --short "-c" --long "--current" --required --default "0" --info "Current Step" &&
        ezb_arg_set --short "-d0" --long "--delete-0" --required --default "0" --info "Delete lines on step 0" &&
        ezb_arg_set --short "-d1" --long "--delete-1" --required --default "1" --info "Delete lines on step 1" &&
        ezb_arg_set --short "-dx" --long "--delete-x" --required --default "1" --info "Delete lines on other steps" &&
        ezb_arg_set --short "-p" --long "--percentage" --type "Flag" --info "Show Percentage" || return 1
    fi
    ezb_function_usage "${@}" && return
    local filler_symbol && filler_symbol="$(ezb_arg_get --short "-f" --long "--filler" --arguments "${@}")" &&
    local blank_symbol && blank_symbol="$(ezb_arg_get --short "-b" --long "--blank" --arguments "${@}")" &&
    local total_steps && total_steps="$(ezb_arg_get --short "-t" --long "--total" --arguments "${@}")" &&
    local current_step && current_step="$(ezb_arg_get --short "-c" --long "--current" --arguments "${@}")" &&
    local show_percentage && show_percentage="$(ezb_arg_get --short "-p" --long "--percentage" --arguments "${@}")" &&
    local delete_0 && delete_0="$(ezb_arg_get --short "-d0" --long "--delete-0" --arguments "${@}")" &&
    local delete_1 && delete_1="$(ezb_arg_get --short "-d1" --long "--delete-1" --arguments "${@}")" &&
    local delete_x && delete_x="$(ezb_arg_get --short "-dx" --long "--delete-x" --arguments "${@}")" || return 1
    [[ "${delete_0}" -lt 0 ]] && ezb_log_error "Invalid value \"${delete_0}\" for \"-d0|--delete-0\"" && return 1
    [[ "${delete_1}" -lt 0 ]] && ezb_log_error "Invalid value \"${delete_1}\" for \"-d1|--delete-1\"" && return 1
    [[ "${delete_x}" -lt 0 ]] && ezb_log_error "Invalid value \"${delete_x}\" for \"-dx|--delete-x\"" && return 1
    [[ "${current_step}" -lt 0 ]] && ezb_log_error "Invalid value \"${current_step}\" for \"-c|--current\"" && return 1
    [[ "${total_steps}" -le 0 ]] && ezb_log_error "Invalid value \"${total_steps}\" for \"-t|--total\"" && return 1
    [[ "${total_steps}" -lt "${current_step}" ]] && ezb_log_error "\"-t|--total\" ${total_steps} less than \"-c|--current\" ${current_step}" && return 1
    local terminal_length="$(tput cols)"
    local percentage_string=""
    local integer_part=0
    if [[ "${show_percentage}" = "${EZB_BOOL_TRUE}" ]]; then
        local percentage="$((${current_step} * 10000 / ${total_steps}))"
        percentage_string="[  0.00%]"
        local decimal_part=0
        if [[ "${percentage}" -gt 0 ]]; then
            integer_part="$((${percentage} / 100))"
            decimal_part="$((${percentage} % 100))"
            if [[ "${integer_part}" -lt 10 ]]; then
                percentage_string="[  ${integer_part}"
            elif [[ "${integer_part}" -eq 100 ]]; then
                percentage_string="[${integer_part}"
            else
                percentage_string="[ ${integer_part}"
            fi
            [[ "${decimal_part}" -lt 10 ]] && percentage_string+=".0${decimal_part}%]" || percentage_string+=".${decimal_part}%]"
        fi
    else
        local length_diff="$((${#total_steps} - ${#current_step}))"
        local percentage_string="["
        local i=0; for ((; i < "${length_diff}"; ++i)); do percentage_string+=" "; done
        percentage_string+="${current_step}/${total_steps}]"
        integer_part="$((${current_step} * 100 / ${total_steps}))"
    fi
    local progress_bar_length="$((${terminal_length} - ${#percentage_string} - 2))"
    local filler_count="$((${progress_bar_length} * ${integer_part} / 100))"
    local blank_count="$((${progress_bar_length} - ${filler_count}))"
    local progress_bar_string=""
    local i=0; for ((; i < "${filler_count}"; ++i)); do progress_bar_string+="${filler_symbol}"; done
    local i=0; for ((; i < "${blank_count}"; ++i)); do progress_bar_string+="${blank_symbol}"; done
    if [[ "${current_step}" -eq 0 ]]; then
        [[ "${delete_0}" -gt 0 ]] && ezb_clear --lines "${delete_0}"
    elif [[ "${current_step}" -eq 1 ]]; then
        [[ "${delete_1}" -gt 0 ]] && ezb_clear --lines "${delete_1}"
    else
        [[ "${delete_x}" -gt 0 ]] && ezb_clear --lines "${delete_x}"
    fi
    echo "${percentage_string}[${progress_bar_string}]"
    # [Demo]
    # list=("I" "think" "this" "is" "a" "great" "script" "to" "demo" "progress" "bar" "!" ":)")
    # o=""; i=0; for d in ${list[@]}; do o+="${d} "; ((++i)); ezb_print_progress -p -c $i -t ${#list[@]} -d1 0 -dx 2; echo $o; done
    # ezb_print_list_with_progress_bar "I" "think" "this" "is" "a" "great" "script" "to" "demo" "progress" "bar" "!" ":)"
}

function ezb_print_list_with_progress_bar() {
    local out=""; local i=0; local data=""
    for data in ${@}; do
        out+="${data} "
        ((++i))
        ezb_print_progress -p -c "${i}" -t "${#}" -d1 0 -dx 2
        echo "${out}"
    done
}


