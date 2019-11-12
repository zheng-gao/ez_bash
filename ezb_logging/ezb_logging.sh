function ez_get_default_log_file() {
    echo "${EZ_BASH_LOGS}/ez_bash.log"
}

function ez_print_log() {
    if [ -z "${1}" ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
        local usage=$(ez_build_usage -o "init" -d "Print log in \"EZ-BASH\" standard log format to console")
        usage+=$(ez_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
        usage+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print")
        ez_print_usage "${usage}"; return 1
    fi
    local time_stamp="$(date '+%Y-%m-%d %H:%M:%S')"; local logger="INFO"; local message=()
    while [ -n "${1}" ]; do
        case "${1-}" in
            "-l" | "--logger") shift; logger="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [ -n "${1}" ]; do
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--logger" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *) echo "[${EZ_BASH_LOG_LOGO}][${time_stamp}]$(ez_log_stack)[ERROR] Unknown argument indentifier \"${1}\""
               echo "[${EZ_BASH_LOG_LOGO}][${time_stamp}]$(ez_log_stack)[ERROR] For more info, please run \"${FUNCNAME[0]} --help\""
               return 1 ;;
        esac
    done
    echo "[${EZ_BASH_LOG_LOGO}][${time_stamp}]$(ez_log_stack 1)[${logger}] ${message[*]}"
}

function ez_print_log_to_file() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_log_to_file" -d "Print log in \"EZ-BASH\" standard log format to file")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
    usage_string+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--file" -d "Log file path")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local logger="INFO"
    local log_file="$(ez_get_default_log_file)"
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-l" | "--logger") shift; logger="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-f" | "--file") shift; log_file="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--logger" ]]; then break; fi
                    if [[ "${1-}" == "-f" ]] || [[ "${1-}" == "--file" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *) echo "[${EZ_BASH_LOG_LOGO}][ERROR] Unknown argument indentifier \"${1}\""
               ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${log_file}" == "" ]]; then log_file="$(ez_get_default_log_file)"; fi
    # Make sure the log_file exists and you have the write permission
    if [ ! -e "${log_file}" ]; then touch "${log_file}"; fi
    if [ ! -f "${log_file}" ] || [ ! -w "${log_file}" ]; then
        ez_print_log -l "ERROR" -m "Log File \"${log_file}\" not exist or not writable"; return 1
    fi
    ez_print_log -l "${logger}" -m "${message[*]}" >> "${log_file}"
}

function ez_print_banner() {
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
        local usage_string=$(ez_build_usage -o "init" -a "ez_print_banner" -d "Print \"EZ-BASH\" standard banner")
        usage_string+=$(ez_build_usage -o "add" -a "-s|--substring" -d "The substring in the spliter, default is \"=\"")
        usage_string+=$(ez_build_usage -o "add" -a "-c|--count" -d "The count of the substrings, default is \"80\"")
        usage_string+=$(ez_build_usage -o "add" -a "-m|--message" -d "Message to print in the banner")
        usage_string+=$(ez_build_usage -o "add" -a "-p|--prefix" -d "Print EZ-BASH log prefix")
        ez_print_usage "${usage_string}"; return 1
    fi
    local count=80
    local substring="="
    local prefix="${EZ_BASH_BOOL_FALSE}"
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--substring") shift; substring="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--count") shift; count="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--prefix") prefix="${EZ_BASH_BOOL_TRUE}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-m" | "--message") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1}" ==  "-s" ]] || [[ "${1}" ==  "--substring" ]]; then break; fi
                    if [[ "${1}" ==  "-c" ]] || [[ "${1}" ==  "--count" ]]; then break; fi
                    if [[ "${1}" ==  "-m" ]] || [[ "${1}" ==  "--message" ]]; then break; fi
                    if [[ "${1}" ==  "-p" ]] || [[ "${1}" ==  "--prefix" ]]; then break; fi
                    message+=("${1-}"); shift
                done ;;
            *)  ez_print_log -l "ERROR" -m "Unknown argument indentifier \"${1}\""
                ez_print_log -m "For more info, please run \"${FUNCNAME[0]} --help\""; return 1; ;;
        esac
    done
    local spliter=$(ez_string_repeat --substring "${substring}" --count ${count})
    if [[ "${prefix}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l INFO -m "${spliter}"
        ez_print_log -l INFO -m "${message[@]}"
        ez_print_log -l INFO -m "${spliter}"
    else
        echo "${spliter}"
        echo "${message[@]}"
        echo "${spliter}"
    fi
}
