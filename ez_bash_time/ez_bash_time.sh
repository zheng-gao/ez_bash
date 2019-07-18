#!/usr/bin/env bash
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_get_timeout_cmd() {
    local os=$(ez_get_os_type)
    if [[ "${os}" == "macos" ]]; then
        if [[ $(ez_command_check -c "gtimeout") == "${EZ_BASH_BOOL_FALSE}" ]]; then
            ez_print_log -l ERROR -m "\"gtimeout\" not found!"
            ez_print_log -l INFO -m "Please run \"brew install coreutils\""
        else
            echo "gtimeout"
        fi
    elif [[ "${os}" == "linux" ]]; then
        echo "timeout"
    fi
}

function ez_get_timestamp_now() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_timestamp_now" -d "Print Timestamp for Now")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--format" -d "Timestamp Format")
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local format="+%Y-%m-%d %H:%M:%S"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    date "${format}"
}

function ez_get_timestamp_from_epoch_seconds() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_timestamp_from_epoch_seconds" -d "Convert Epoch Seconds to Timestamp")
    usage_string+=$(ez_build_usage -o "add" -a "-e|--epoch" -d "Epoch Seconds")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--format" -d "Timestamp Format")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local epoch_second=""
    local format="+%Y-%m-%d %H:%M:%S"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-e" | "--epoch") shift; epoch_second=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    local os=$(ez_get_os_type)
    if [[ "${os}" == "macos" ]]; then
        date -r "${epoch_second}" "${format}"
    elif [[ "${os}" == "linux" ]]; then
        date "${format}" -d "@${epoch_second}"
    fi
}

function ez_get_epoch_seconds_from_timestamp() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_epoch_seconds_from_timestamp" -d "Convert Human Readable Timestamp to Epoch Seconds")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--date" -d "YYYY-MM-DD, default is now")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--time" -d "HH:mm:SS, default is now")
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local date=""
    local time=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--date") shift; date=${1-} ;;
            "-t" | "--time") shift; time=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${date}" == "" ]] && [[ "${time}" == "" ]]; then date "+%s"
    elif [[ "${date}" == "" ]]; then ez_print_log -l ERROR -m "Date cannot be empty if Time is given"; ez_print_usage "${usage_string}"; return 1
    elif [[ "${time}" == "" ]]; then ez_print_log -l ERROR -m "Time cannot be empty if Date is given"; ez_print_usage "${usage_string}"; return 1
    else
        local os=$(ez_get_os_type)
        if [[ "${os}" == "macos" ]]; then
            date -j -f "%Y-%m-%d %H:%M:%S" "${date} ${time}" "+%s"
        elif [[ "${os}" == "linux" ]]; then
            date -d "${date} ${time}" "+%s"
        fi
    fi
}

function ez_get_readable_time_from_seconds() {
    local output_formats=("Mini" "Short" "Long")
    local output_formats_string=$(ez_print_array_with_delimiter -d ", " -a ${output_formats[@]})
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_readable_time_from_seconds" -d "Convert Seconds to Human Readable Timestamp")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--seconds" -d "Input Seconds")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--format" -d "Output Format [${output_formats_string[@]}], default = Mini")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local seconds=""
    local format=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--seconds") shift; seconds=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${format}" == "" ]]; then format="Mini"; fi
    if [[ $(ez_check_item_in_array -i "${format}" -a "${output_formats[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l ERROR -m "Invalid format \"${format}\""
        ez_print_usage "${usage_string}"; return 1
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

function ez_get_duration_from_epoch_seconds_diff() {
    local usage_string=$(ez_build_usage -o "init" -a "get_duration_from_epoch_seconds_diff" -d "Print the time difference between start time and end time")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--start" -d "Start Time Epoch Seconds")
    usage_string+=$(ez_build_usage -o "add" -a "-e|--end" -d "End Time Epoch Seconds")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local start_time=""
    local end_time=""
    local format="+%Y-%m-%d %H:%M:%S"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--start") shift; start_time=${1-} ;;
            "-e" | "--end") shift; end_time=${1-} ;;
            "-f" | "--format") shift; format=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
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
    ez_get_readable_time_from_seconds -s ${duration_seconds}
}

