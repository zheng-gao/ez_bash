###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "date" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_clock() {
    ezb_time_now; sleep 1; while true; do ezb_clear -l 1; ezb_time_now; sleep 1; done
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
    else ezb_log_error "Unsupported ${os}" && return 2
    fi
}

function ezb_time_to_epoch_seconds() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-t" --long "--timestamp" --required --info "Timestamp" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi
    ezb_function_usage "${@}" && return
    local timestamp && timestamp="$(ezb_arg_get --short "-t" --long "--timestamp" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then date -j -f "${format}" "${timestamp}" "+%s"
    elif [[ "${os}" = "linux" ]]; then date -d "${timestamp}" "+%s"
    else ezb_log_error "Unsupported ${os}" && return 2
    fi
}

function ezb_time_offset() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-t" --long "--timestamp" --required --info "Base Timestamp" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" &&
        ezb_arg_set --short "-u" --long "--unit" --required --default "seconds" --choices "seconds" "minutes" "hours" "days" "weeks" --info "Offset Unit" &&
        ezb_arg_set --short "-o" --long "--offset" --required --default "0" --info "Offset Value" || return 1
    fi
    ezb_function_usage "${@}" && return
    local timestamp && timestamp="$(ezb_arg_get --short "-t" --long "--timestamp" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" &&
    local unit && unit="$(ezb_arg_get --short "-u" --long "--unit" --arguments "${@}")" &&
    local offset && offset="$(ezb_arg_get --short "-o" --long "--offset" --arguments "${@}")" || return 1
    local unit_value=0 epoch_seconds=$(ezb_time_to_epoch_seconds --timestamp "${timestamp}" --format "${format}")
    case "${unit}" in
        "seconds") unit_value=1 ;;
        "minutes") unit_value=60 ;;
          "hours") unit_value=3600 ;;
           "days") unit_value=86400 ;;
          "weeks") unit_value=604800 ;;
                *) unit_value=0 ;;
    esac
    ((epoch_seconds += unit_value * offset))
    ezb_time_from_epoch_seconds --epoch "${epoch_seconds}" --format "+${format}"
}

function ezb_time_seconds_to_readable() {
    if ezb_function_unregistered; then
        local output_formats=("Short" "Long")
        ezb_arg_set --short "-s" --long "--seconds" --required --default "0" --info "Input Seconds" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "Short" --choices "${output_formats[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local seconds && seconds="$(ezb_arg_get --short "-s" --long "--seconds" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local output=""
    if [[ "${seconds}" -lt 0 ]]; then
        seconds="${seconds:1}"
        output="-"
    fi
    local days=$((seconds / 86400))
    local hours=$((seconds / 3600 % 24))
    local minutes=$((seconds / 60 % 60))
    local seconds=$((seconds % 60))
    if [ ${days} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${days}d" || output+="${days} Days "; fi
    if [ ${hours} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${hours}h" || output+="${hours} Hours "; fi
    if [ ${minutes} -gt 0 ]; then [[ "${format}" = "Short" ]] && output+="${minutes}m" || output+="${minutes} Minutes "; fi
    if [ ${seconds} -ge 0 ]; then [[ "${format}" = "Short" ]] && output+="${seconds}s" || output+="${seconds} Seconds"; fi
    echo "${output}"
}

function ezb_time_elapsed_epoch() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-s" --long "--start" --required --info "Start Time Epoch Seconds" &&
        ezb_arg_set --short "-e" --long "--end" --required --info "End Time Epoch Seconds" || return 1
    fi
    ezb_function_usage "${@}" && return
    local start && start="$(ezb_arg_get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ezb_arg_get --short "-e" --long "--end" --arguments "${@}")" || return 1
    ezb_time_seconds_to_readable --seconds "$((end - start))"
}

function ezb_time_elapsed() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-s" --long "--start" --required --info "Start Timestamp" &&
        ezb_arg_set --short "-e" --long "--end" --required --info "End Timestamp" &&
        ezb_arg_set --short "-f" --long "--format" --required --default "%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi
    ezb_function_usage "${@}" && return
    local start && start="$(ezb_arg_get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ezb_arg_get --short "-e" --long "--end" --arguments "${@}")" &&
    local format && format="$(ezb_arg_get --short "-f" --long "--format" --arguments "${@}")" || return 1
    local start_epoch_seconds=$(ezb_time_to_epoch_seconds --timestamp "${start}" --format "${format}")
    local end_epoch_seconds=$(ezb_time_to_epoch_seconds --timestamp "${end}" --format "${format}")
    ezb_time_seconds_to_readable --seconds "$((end_epoch_seconds - start_epoch_seconds))"
}



