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

function ezb_cmd_check() {
    if ! which "${1}" &> "${EZB_DIR_LOGS}/null"; then return 1; else return 0; fi
}

function ezb_to_lower() {
    tr "[:upper:]" "[:lower:]" <<< "${@}"
}

function ezb_to_upper() {
    tr "[:lower:]" "[:upper:]" <<< "${@}"
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

function ezb_split() {
    local delimiter="${1}"; local string="${2}"
    local d_length="${#delimiter}"; local s_length="${#string}"
    local item=""; local tmp=""; local k=0
    while [[ "${k}" -lt "${s_length}" ]]; do
        tmp="${string:k:${d_length}}"
        if [[ "${tmp}" = "${delimiter}" ]]; then
            [[ -n "${item}" ]] && echo "${item}"
            item=""; ((k += d_length))
        else
            item+="${string:k:1}"; ((++k))
        fi
        [[ "${k}" -ge "${s_length}" ]] && [[ -n "${item}" ]] && echo "${item}"
    done
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
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
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
    [[ -z "${1}" ]] && ezb_log_error "Empty file path" && return 1
    local file_path="${1}"
    [[ ! -f "${file_path}" ]] && ezb_log_error "Invalid file path \"${file_path}\"" && return 2
    [[ ! -r "${file_path}" ]] && ezb_log_error "Unreadable file \"${file_path}\"" && return 3
    if ! source "${file_path}"; then ezb_log_error "Failed to source \"${file_path}\"" && return 4; fi
}

function ezb_source_dir() {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "Source whole directory")
        usage+=$(ezb_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
        usage+=$(ezb_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
        ezb_print_usage "${usage}"
        return
    fi
    local path="."; local exclude=""
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1} && [ -n "${1}" ] && shift ;;
            "-r" | "--exclude") shift; exclude=${1} && [ -n "${1}" ] && shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${path}" ]] && ezb_log_error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    [[ ! -d "${path}" ]] && ezb_log_error "\"${path}\" is not a directory" && return 2
    [[ ! -r "${path}" ]] && ezb_log_error "Cannot read directory \"${dir_path}\"" && return 3
    if [[ "${exclude}" = "" ]]; then
        for sh_file_path in $(find "${path}" -type f -name "*.sh"); do
            if ! ezb_source "${sh_file_path}"; then return 4; fi
        done
    else
        for sh_file_path in $(find "${path}" -type f -name "*.sh" | grep -v "${exclude}"); do
            if ! ezb_source "${sh_file_path}"; then return 4; fi
        done
    fi
}

function ezb_log() {
    local valid_output_to=("Console" "File" "${EZB_OPT_ALL}")
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "Print log to file in \"EZ-BASH\" standard log format")
        usage+=$(ezb_build_usage -o "add" -a "-l|--logger" -d "Logger type, default = \"INFO\"")
        usage+=$(ezb_build_usage -o "add" -a "-f|--file" -d "Log file path, default = \"${EZB_DEFAULT_LOG}\"")
        usage+=$(ezb_build_usage -o "add" -a "-m|--message" -d "The message to print")
        usage+=$(ezb_build_usage -o "add" -a "-s|--simple" -d "Hide function stack")
        usage+=$(ezb_build_usage -o "add" -a "-o|--output-to" -d "Choose from: [$(ezb_join ', ' ${valid_output_to[@]})], default = \"Console\"")
        ezb_print_usage "${usage}"
        return
    fi
    declare -A arg_set_of_ezb_log_to_file=(
        ["-l"]="1" ["--logger"]="1" ["-f"]="1" ["--file"]="1" ["-m"]="1" ["--message"]="1"
        ["-s"]="1" ["--simple"]="1" ["-o"]="1" ["--output-to"]="1"
    )
    local logger="INFO"; local file=""; local message=()
    local simple="${EZB_BOOL_FALSE}"; local output_to="Console"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-l" | "--logger") shift; logger=${1}; [[ -n "${1}" ]] && shift ;;
            "-f" | "--file") shift; file=${1}; [[ -n "${1}" ]] && shift ;;
            "-o" | "--output-to") shift; output_to=${1}; [[ -n "${1}" ]] && shift ;;
            "-s" | "--simple") shift; simple="${EZB_BOOL_TRUE}" ;;
            "-m" | "--message") shift;
                while [[ -n "${1}" ]]; do [[ -n "${arg_set_of_ezb_log_to_file["${1}"]}" ]] && break; message+=("${1}"); shift; done ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    if ezb_exclude "${output_to}" "${valid_output_to[@]}"; then
        ezb_log_error "Invalid value \"${output_to}\" for \"-o|--output-to\", please choose from [$(ezb_join ', ' ${valid_output_to[@]})]"
        return 2
    fi
    local function_stack=""
    [[ "${simple}" = "${EZB_BOOL_FALSE}" ]] && function_stack="$(ezb_log_stack 1)"
    if [[ "${output_to}" = "Console" ]] || [[ "${output_to}" = "${EZB_OPT_ALL}" ]]; then
        if [[ "$(ezb_to_lower ${logger})" = "error" ]]; then
            (>&2 echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]${function_stack}[${logger}] ${message[@]}")
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]${function_stack}[${logger}] ${message[@]}"
        fi
    fi
    if [[ "${output_to}" = "File" ]] || [[ "${output_to}" = "${EZB_OPT_ALL}" ]]; then
        [[ -z "${file}" ]] && file="${EZB_DEFAULT_LOG}"
        # Make sure the log_file exists and you have the write permission
        [[ ! -e "${file}" ]] && touch "${file}"
        [[ ! -f "${file}" ]] && ez_log_error "Log File \"${file}\" not exist" && return 3
        [[ ! -w "${file}" ]] && ez_log_error "Log File \"${file}\" not writable" && return 3
        echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZB_LOGO}]${function_stack}[${logger}] ${message[@]}" >> "${file}"
    fi
}

function ezb_variable_check() {
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then 
        local usage=$(ezb_build_usage -o "init" -d "Check if the variable is set or not")
        usage+=$(ezb_build_usage -o "add" -a "-n|--name" -d "Variable Name")
        usage+=$(ezb_build_usage -o "add" -a "-v|--verbose" -d "Print Result")
        ezb_print_usage "${usage}" && return
    fi
    local name=""
    local verbose="${EZB_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-n" | "--name") shift; name="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-v" | "--verbose") shift; verbose="${EZB_BOOL_TRUE}" ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${name}" ]] && ezb_log_error "Invalid value \"${name}\" for \"-n|--name\"" && return 1
    if [[ -v "${name}" ]]; then
        [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "Variable \"${name}\" is set to \"${!name}\""
        return 0
    else
        [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "Variable \"${name}\" is unset"
        return 1
    fi
}

