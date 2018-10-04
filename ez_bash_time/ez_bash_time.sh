#!/usr/bin/env bash
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_time.sh"
if [[ "${0}" != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        echo "[EZ-BASH][ERROR] ${THIS_SCRIPT_NAME} is not runnable!"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"
        exit 1
    fi
fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if ! source "${EZ_BASH_HOME}/ez_bash_os/ez_bash_os.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_log/ez_bash_log.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_variables/ez_bash_variables.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_sanity_check/ez_bash_sanity_check.sh"; then exit 1; fi

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

function ez_get_epoch_seconds() {
    date +%s
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
        date "${format}" --date="${epoch_second}"
    fi
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

function ez_sleep() {
    local valid_unit=("Day" "Hour" "Minute" "Second")
    local valid_unit_string=$(ez_print_array_with_delimiter -d ", " -a ${valid_unit[@]})
    local usage_string=$(ez_build_usage -o "init" -a "ez_sleep" -d "Sleep for a while")
    usage_string+=$(ez_build_usage -o "add" -a "-u|--unit" -d "Please choose from [${valid_unit_string[@]}], default = Second")
    usage_string+=$(ez_build_usage -o "add" -a "-v|--value" -d "Number of unit to sleep")
    usage_string+=$(ez_build_usage -o "add" -a "-n|--interval" -d "Number of seconds to refresh the output, 0 for no output, default = 1")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local unit=""
    local value=""
    local interval=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-u" | "--unit") shift; unit=${1-} ;;
            "-v" | "--value") shift; value=${1-} ;;
            "-n" | "--interval") shift; interval=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if [[ "${unit}" == "" ]]; then unit="Second"; fi
    if [[ $(ez_check_item_in_array -i "${unit}" -a "${valid_unit[@]}") != "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l ERROR -m "Invalid unit \"${unit}\""
        ez_print_usage "${usage_string}"; return 1
    fi
    if [[ "${value}" == "" ]] || [ ${value} -lt 0 ]; then
        ez_print_log -l ERROR -m "Invalid value \"${value}\""
        ez_print_usage "${usage_string}"; return 1
    fi
    if [[ "${interval}" == "" ]] || [ ${interval} -lt 0 ]; then interval=1; fi
    local timeout_in_seconds=0
    if [[ "${unit}" == "D" ]] || [[ "${unit}" == "Day" ]]; then timeout_in_seconds=$((value * 86400))
    elif [[ "${unit}" == "H" ]] || [[ "${unit}" == "Hour" ]]; then timeout_in_seconds=$((value * 3600))
    elif [[ "${unit}" == "M" ]] || [[ "${unit}" == "Minute" ]]; then timeout_in_seconds=$((value * 60))
    else timeout_in_seconds=${value}; fi
    if [[ "${interval}" == 0 ]]; then sleep ${timeout_in_seconds}; return; fi
    local wait_seconds=0
    local timeout_string=$(ez_get_readable_time_from_seconds -s ${timeout_in_seconds} -f "Mini")
    local wait_seconds_string=$(ez_get_readable_time_from_seconds -s ${wait_seconds} -f "Mini")
    ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
    while [ ${wait_seconds} -lt ${timeout_in_seconds} ]; do
        local seconds_left=$((timeout_in_seconds - wait_seconds))
        if [ $seconds_left -ge $interval ]; then
            ((wait_seconds+=${interval}))
            sleep $interval
            tput cuu1 #Move cursor up by one line
            tput el #Clear the line
            wait_seconds_string=$(ez_get_readable_time_from_seconds -s ${wait_seconds} -f "Mini")
            ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
            
        else
            wait_seconds=$timeout_in_seconds
            sleep $seconds_left
            tput cuu1 #Move cursor up by one line
            tput el #Clear the line
            wait_seconds_string=$(ez_get_readable_time_from_seconds -s ${wait_seconds} -f "Mini")
            ez_print_log -l INFO -m "Sleeping... (${wait_seconds_string} / ${timeout_string})"
        fi
    done
}



