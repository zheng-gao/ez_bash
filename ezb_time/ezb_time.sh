function ezb_time_now() {
    [[ -z "${1}" ]] && date "+%Y-%m-%d %H:%M:%S" || date "${1}"
}

function ezb_time_clock() {
    ezb_time_now; sleep 1;
    while true; do ez_clear -l 1; ezb_time_now; sleep 1; done
}

function ezb_time_from_epoch_seconds() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-e" --long "--epoch" --required --default "0" --info "Epoch Seconds" &&
        ezb_set_arg --short "-f" --long "--format" --required --default "+%Y-%m-%d %H:%M:%S" --info "Timestamp Format" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local epoch; epoch="$(ezb_get_arg --short "-e" --long "--epoch" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local format; format="$(ezb_get_arg --short "-f" --long "--format" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then date -r "${epoch}" "${format}"
    elif [[ "${os}" = "linux" ]]; then date "${format}" -d "@${epoch}"
    else ezb_log_error "Bad ${os}" && return 2
    fi
}

function ezb_time_to_epoch_seconds() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-d" --long "--date" --required --default "Today" --info "YYYY-MM-DD" &&
        ezb_set_arg --short "-t" --long "--time" --required --default "Now" --info "HH:mm:SS" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local date; date="$(ezb_get_arg --short "-d" --long "--date" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local time; time="$(ezb_get_arg --short "-t" --long "--time" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [[ "${date}" = "Today" ]] && date=$(date "+%F")
    [[ "${time}" = "Now" ]] && time=$(date "+%H:%M:%S")
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then date -j -f "%Y-%m-%d %H:%M:%S" "${date} ${time}" "+%s"
    elif [[ "${os}" = "linux" ]]; then date -d "${date} ${time}" "+%s"
    else ezb_log_error "Bad ${os}" && return 2
    fi
}

function ezb_seconds_to_readable_time() {
    local output_formats=("Mini" "Short" "Long")
    local output_formats_string=$(ezb_join ', ' ${output_formats[@]})
    local usage_string=$(ezb_build_usage -o "init" -d "Convert Seconds to Human Readable Timestamp")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--seconds" -d "Input Seconds")
    usage_string+=$(ezb_build_usage -o "add" -a "-f|--format" -d "Output Format [${output_formats_string[@]}], default = Mini")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local seconds=""
    local format=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--seconds") shift; seconds=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ezb_log_error "Unknown argument \"$1\""
                ezb_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${format}" == "" ]]; then format="Mini"; fi
    if ezb_excludes "${format}" "${output_formats[@]}"; then
        ezb_log_error "Invalid format \"${format}\""
        ezb_print_usage "${usage_string}"; return 1
    fi
    local days=$((seconds / 86400))
    local hours=$((seconds / 3600 % 24))
    local minutes=$((seconds / 60 % 60))
    local seconds=$((seconds % 60))
    local output_string=""
    if [[ "${format}" == "Mini" ]]; then
        if [ ${days} -gt 0 ]; then output_string+="${days}d"; fi
        if [ ${hours} -gt 0 ]; then output_string+="${hours}h"; fi
        if [ ${minutes} -gt 0 ]; then output_string+="${minutes}m"; fi
        if [ ${seconds} -ge 0 ]; then output_string+="${seconds}s"; fi
    elif [[ "${format}" == "Short" ]]; then
        output_string="${days} D ${hours} H ${minutes} M ${seconds} S"
    elif [[ "${format}" == "Long" ]]; then
        output_string="${days} Days ${hours} Hours ${minutes} Minutes ${seconds} Seconds"
    fi
    echo "${output_string}"
}

function ezb_time_diff_from_epoch_seconds_diff() {
    local usage_string=$(ezb_build_usage -o "init" -d "Print the time difference between start time and end time")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--start" -d "Start Time Epoch Seconds")
    usage_string+=$(ezb_build_usage -o "add" -a "-e|--end" -d "End Time Epoch Seconds")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local start_time=""
    local end_time=""
    local format="+%Y-%m-%d %H:%M:%S"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--start") shift; start_time=${1-} ;;
            "-e" | "--end") shift; end_time=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *) ezb_log_error "Unknown argument \"$1\""; ezb_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${start_time}" == "" ]]; then
        ezb_log_error "Start Time cannot be empty"
        return 1
    elif [[ "${end_time}" == "" ]]; then
        ezb_log_error "End Time cannot be empty"
        return 1
    fi
    if [ "${start_time}" -gt "${end_time}" ]; then
        ezb_log_error "Start Time \"${start_time}\" Cannot Be Greater Than End Time \"${end_time}\""
        return 1
    fi
    local duration_seconds=$((end_time - start_time))
    ezb_seconds_to_readable_time -s ${duration_seconds}
}

