###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_LOGO="EZ-BASH"

EZB_BOOL_TRUE="True"
EZB_BOOL_FALSE="False"

EZB_OPT_ALL="All"
EZB_OPT_ANY="Any"
EZB_OPT_NONE="None"

EZB_CHAR_SHARP="EZB_SHARP"
EZB_CHAR_SPACE="EZB_SPACE"
EZB_CHAR_NON_SPACE_DELIMITER="#"

EZB_DIR_WORKSPACE="/var/tmp/ezb_workspace"; mkdir -p "${EZB_DIR_WORKSPACE}"
EZB_DIR_LOGS="${EZB_DIR_WORKSPACE}/logs"; mkdir -p "${EZB_DIR_LOGS}"
EZB_DIR_DATA="${EZB_DIR_WORKSPACE}/data"; mkdir -p "${EZB_DIR_DATA}"

EZB_DEFAULT_LOG="${EZB_DIR_LOGS}/ez_bash.log"
###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_check_cmd() {
    if ! which "${1}" &> "${EZB_DIR_LOGS}/null"; then return 1; else return 0; fi
}

function ezb_contain() {
    # ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
    for data in "${@:2}"; do [[ "${1}" = "${data}" ]] && return 0; done; return 1
}

function ezb_exclude() {
    # ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
    for data in "${@:2}"; do [[ "${1}" = "${data}" ]] && return 1; done; return 0
}

function ezb_join() {
    local delimiter="${1}"; local i=0; local out_put=""
    for data in "${@:2}"; do [ "${i}" -eq 0 ] && out_put="${data}" || out_put+="${delimiter}${data}"; ((++i)); done
    echo "${out_put}"
}

function ezb_log_stack() {
    local ignore_top_x="${1}"; local stack=""; local i=$((${#FUNCNAME[@]} - 1))
    if [[ -n "${ignore_top_x}" ]]; then
        for ((; i > "${ignore_top_x}"; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    else
        # i > 0 to ignore self "ezb_log_stack"
        for ((; i > 0; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    fi
    echo "${stack}"
}

function ezb_log_error() {
    (>&2 echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]$(ezb_log_stack 1)[ERROR] ${@}")
}

function ezb_log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]$(ezb_log_stack 1)[INFO] ${@}"
}

function ezb_log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]$(ezb_log_stack 1)[WARNING] ${@}"
}

function ezb_print_usage() {
    # local tab_size=30
    # tabs "${tab_size}" && (>&2 printf "${1}\n") && tabs
    # column delimiter = "#"
    echo; printf "${1}\n" | column -s "#" -t; echo
}

function ezb_build_usage() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        # column delimiter = "#"
        local usage="[Function Name]#ezb_build_usage#\n[Function Info]#EZ-BASH usage builder\n"
        usage+="-o|--operation#Choose from: [\"add\", \"init\"]\n"
        usage+="-a|--argument#Argument Name\n"
        usage+="-d|--description#Argument Description\n"
        ezb_print_usage "${usage}"
        return
    fi
    local operation=""; local argument=""; local description="No Description"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-o" | "--operation") shift; operation=${1} && [ -n "${1}" ] && shift ;;
            "-a" | "--argument") shift; argument=${1} && [ -n "${1}" ] && shift ;;
            "-d" | "--description") shift; description=${1} && [ -n "${1}" ] && shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    # column delimiter = "#"
    case "${operation}" in
        "init")
            [[ -z "${argument}" ]] && argument="${FUNCNAME[1]}"
            echo "[Function Name]#${argument}"
            echo "[Function Info]#${description}\n" ;;
        "add")
            echo "${argument}#${description}\n" ;;
        *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
    esac
}

function ezb_source() {
    [ -z "${1}" ] && ezb_log_error "Empty file path" && return 1
    local file_path="${1}"
    [ ! -f "${file_path}" ] && ezb_log_error "Invalid file path \"${file_path}\"" && return 2
    [ ! -r "${file_path}" ] && ezb_log_error "Unreadable file \"${file_path}\"" && return 3
    if ! source "${file_path}"; then ezb_log_error "Failed to source \"${file_path}\"" && return 4; fi
}

function ezb_source_dir() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        local usage=$(ezb_build_usage -o "init" -d "Source whole directory")
        usage+=$(ezb_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
        usage+=$(ezb_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
        ezb_print_usage "${usage}"
        return
    fi
    local path="."; local exclude=""
    while [ -n "${1}" ]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1} && [ -n "${1}" ] && shift ;;
            "-r" | "--exclude") shift; exclude=${1} && [ -n "${1}" ] && shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [ -z "${path}" ] && ezb_log_error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    [ ! -d "${path}" ] && ezb_log_error "\"${path}\" is not a directory" && return 2
    [ ! -r "${path}" ] && ezb_log_error "Cannot read directory \"${dir_path}\"" && return 3
    if [ "${exclude}" = "" ]; then
        for sh_file_path in $(find "${path}" -type f -name "*.sh"); do
            if ! ezb_source "${sh_file_path}"; then return 4; fi
        done
    else
        for sh_file_path in $(find "${path}" -type f -name "*.sh" | grep -v "${exclude}"); do
            if ! ezb_source "${sh_file_path}"; then return 4; fi
        done
    fi
}

function ez_print_log() {
    if [ -z "${1}" ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
        local usage=$(ezb_build_usage -o "init" -d "Print log in \"EZ-BASH\" standard log format to console")
        usage+=$(ezb_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
        usage+=$(ezb_build_usage -o "add" -a "-m|--message" -d "Message to print")
        ezb_print_usage "${usage}"; return 1
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
            *) echo "[${EZB_LOGO}][${time_stamp}]$(ezb_log_stack)[ERROR] Unknown argument indentifier \"${1}\""
               echo "[${EZB_LOGO}][${time_stamp}]$(ezb_log_stack)[ERROR] For more info, please run \"${FUNCNAME[0]} --help\""
               return 1 ;;
        esac
    done
    echo "[${EZB_LOGO}][${time_stamp}]$(ezb_log_stack 1)[${logger}] ${message[*]}"
}

function ez_print_log_to_file() {
    local usage_string=$(ezb_build_usage -o "init" -a "ez_print_log_to_file" -d "Print log in \"EZ-BASH\" standard log format to file")
    usage_string+=$(ezb_build_usage -o "add" -a "-l|--logger" -d "Logger type such as INFO, WARN, ERROR, ...")
    usage_string+=$(ezb_build_usage -o "add" -a "-m|--message" -d "Message to print")
    usage_string+=$(ezb_build_usage -o "add" -a "-f|--file" -d "Log file path")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local logger="INFO"
    local log_file="${EZB_DEFAULT_LOG}"
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
            *) echo "[${EZB_LOGO}][ERROR] Unknown argument indentifier \"${1}\""
               ezb_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${log_file}" == "" ]]; then log_file="${EZB_DEFAULT_LOG}"; fi
    # Make sure the log_file exists and you have the write permission
    if [ ! -e "${log_file}" ]; then touch "${log_file}"; fi
    if [ ! -f "${log_file}" ] || [ ! -w "${log_file}" ]; then
        ez_print_log -l "ERROR" -m "Log File \"${log_file}\" not exist or not writable"; return 1
    fi
    ez_print_log -l "${logger}" -m "${message[*]}" >> "${log_file}"
}