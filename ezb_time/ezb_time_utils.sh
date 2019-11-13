function ezb_now() {
    date "+%Y-%m-%d %H:%M:%S"
}

function ezb_clock() {
    ezb_now; sleep 1;
    while true; do ez_clear -l 1; ezb_now; sleep 1; done
}

function ezb_cmd_timeout() {
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! ezb_check_cmd "gtimeout"; then ezb_log_error "Not found \"gtimeout\", please run \"brew install coreutils\""
        else echo "gtimeout"; fi
    elif [[ "${os}" = "linux" ]]; then
        echo "timeout" # Should be installed by default
    fi
}

function ezb_epoch_seconds_to_time() {
    local usage_string=$(ezb_build_usage -o "init" -d "Convert Epoch Seconds to Timestamp")
    usage_string+=$(ezb_build_usage -o "add" -a "-e|--epoch" -d "Epoch Seconds")
    usage_string+=$(ezb_build_usage -o "add" -a "-f|--format" -d "Timestamp Format")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local epoch_second=""
    local format="+%Y-%m-%d %H:%M:%S"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-e" | "--epoch") shift; epoch_second=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ezb_log_error "Unknown argument \"$1\""
                ezb_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    local os=$(ezb_os_name)
    if [[ "${os}" == "macos" ]]; then
        date -r "${epoch_second}" "${format}"
    elif [[ "${os}" == "linux" ]]; then
        date "${format}" -d "@${epoch_second}"
    fi
}

function ezb_time_to_epoch_seconds() {
    local usage_string=$(ezb_build_usage -o "init" -d "Convert Human Readable Timestamp to Epoch Seconds")
    usage_string+=$(ezb_build_usage -o "add" -a "-d|--date" -d "YYYY-MM-DD, default is now")
    usage_string+=$(ezb_build_usage -o "add" -a "-t|--time" -d "HH:mm:SS, default is now")
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local date=""
    local time=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--date") shift; date=${1-} ;;
            "-t" | "--time") shift; time=${1-} ;;
            *)
                ezb_log_error "Unknown argument \"$1\""
                ezb_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${date}" == "" ]] && [[ "${time}" == "" ]]; then date "+%s"
    elif [[ "${date}" == "" ]]; then ezb_log_error "Date cannot be empty if Time is given"; ezb_print_usage "${usage_string}"; return 1
    elif [[ "${time}" == "" ]]; then ezb_log_error "Time cannot be empty if Date is given"; ezb_print_usage "${usage_string}"; return 1
    else
        local os=$(ezb_os_name)
        if [[ "${os}" == "macos" ]]; then
            date -j -f "%Y-%m-%d %H:%M:%S" "${date} ${time}" "+%s"
        elif [[ "${os}" == "linux" ]]; then
            date -d "${date} ${time}" "+%s"
        fi
    fi
}

function ezb_seconds_to_readable_time() {
    local output_formats=("Mini" "Short" "Long")
    local output_formats_string=$(ez_print_array_with_delimiter -d ", " -a ${output_formats[@]})
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
    if [[ $(ez_check_item_in_array -i "${format}" -a "${output_formats[@]}") != "${EZB_BOOL_TRUE}" ]]; then
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
        ez_print_log -l "ERROR" -m "Start Time cannot be empty"
        return 1
    elif [[ "${end_time}" == "" ]]; then
        ez_print_log -l "ERROR" -m "End Time cannot be empty"
        return 1
    fi
    if [ "${start_time}" -gt "${end_time}" ]; then
        ez_print_log -l "ERROR" -m "Start Time \"${start_time}\" Cannot Be Greater Than End Time \"${end_time}\""
        return 1
    fi
    local duration_seconds=$((end_time - start_time))
    ezb_seconds_to_readable_time -s ${duration_seconds}
}

