###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "date" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_clock() {
    ezb_time_now; sleep 1;
    while true; do ezb_clear -l 1; ezb_now; sleep 1; done
}

function ezb_time_from_epoch_seconds() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-e" --long "--epoch" --required --default "0" --info "Epoch Seconds" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "+%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local epoch && epoch="$(ezb_arg_get --short "-e" --long "--epoch" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then date -r "${epoch}" "${format}"
    elif [[ "${os}" = "linux" ]]; then date "${format}" -d "@${epoch}"
    else ezb_log_error "Bad ${os}" && return 2
    fi
}

function ezb_time_to_epoch_seconds() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--date" --required --default "Today" --info "YYYY-MM-DD" &&
        ezb_arg_set --short "-t" --long "--time" --required --default "Now" --info "HH:mm:SS" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local date && date="$(ezb_arg_get --short "-d" --long "--date" --arguments "${@}")" &&
    local time && time="$(ezb_arg_get --short "-t" --long "--time" --arguments "${@}")" || return 1
    [[ "${date}" = "Today" ]] && date=$(date "+%F")
    [[ "${time}" = "Now" ]] && time=$(date "+%H:%M:%S")
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then date -j -f "%Y-%m-%d %H:%M:%S" "${date} ${time}" "+%s"
    elif [[ "${os}" = "linux" ]]; then date -d "${date} ${time}" "+%s"
    else ezb_log_error "Bad ${os}" && return 2
    fi
}

function ezb_time_seconds_to_readable() {
    if ezb_function_unregistered; then
        local output_formats=("Mini" "Short" "Long")
        ezb_arg_set --short "-s" --long "--seconds" --required --default "0" --info "Input Seconds" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "Mini" --choices "${output_formats[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local seconds && seconds="$(ezb_arg_get --short "-s" --long "--seconds" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local days=$((seconds / 86400))
    local hours=$((seconds / 3600 % 24))
    local minutes=$((seconds / 60 % 60))
    local seconds=$((seconds % 60))
    local output_string=""
    if [[ "${format}" = "Mini" ]]; then
        if [ ${days} -gt 0 ]; then output_string+="${days}d"; fi
        if [ ${hours} -gt 0 ]; then output_string+="${hours}h"; fi
        if [ ${minutes} -gt 0 ]; then output_string+="${minutes}m"; fi
        if [ ${seconds} -ge 0 ]; then output_string+="${seconds}s"; fi
    elif [[ "${format}" = "Short" ]]; then output_string="${days} D ${hours} H ${minutes} M ${seconds} S"
    elif [[ "${format}" = "Long" ]]; then output_string="${days} Days ${hours} Hours ${minutes} Minutes ${seconds} Seconds"
    fi
    echo "${output_string}"
}

function ezb_time_elapsed() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-s" --long "--start" --required --info "Start Time Epoch Seconds" &&
        ezb_arg_set --short "-e" --long "--end" --required --info "End Time Epoch Seconds" || return 1
    fi
    ezb_function_usage "${@}" && return
    local start && start="$(ezb_arg_get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ezb_arg_get --short "-e" --long "--end" --arguments "${@}")" || return 1
    [[ "${start}" -gt "${end}" ]] && ezb_log_error "Start Time \"${start}\" Cannot Be Greater Than End Time \"${end}\"" && return 1
    ezb_time_seconds_to_readable -s "$((end - start))"
}

