###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
[ -z "${EZ_BASH_HOME}" ] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
export EZ_BASH_WORKSPACE="/var/tmp/ez_bash_workspace"; mkdir -p "${EZ_BASH_WORKSPACE}"
export EZ_BASH_LOG_LOGO="EZ-BASH"
export EZ_BASH_TAB_SIZE="30"
export EZ_BASH_BOOL_TRUE="True"
export EZ_BASH_BOOL_FALSE="False"
export EZ_BASH_SPACE="SPACE"
export EZ_BASH_ALL="ALL"
export EZ_BASH_NONE="NONE"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_contain() {
    # ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
    for data in "${@:2}"; do [[ "${1}" = "${data}" ]] && return 0; done; return 1
}

function ez_exclude() {
    # ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
    for data in "${@:2}"; do [[ "${1}" = "${data}" ]] && return 1; done; return 0
}

function ez_join() {
    local delimiter="${1}"; local i=0; local out_put=""
    for data in "${@:2}"; do [ "${i}" -eq 0 ] && out_put="${data}" || out_put+="${delimiter}${data}"; ((++i)); done
    echo "${out_put}"
}

function ez_log_stack() {
    local ignore_top_x="${1}"; local stack=""; local i=$((${#FUNCNAME[@]} - 1))
    if [ -n "${ignore_top_x}" ]; then
        for ((; i > "${ignore_top_x}"; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    else
        # i > 0 to ignore self "ez_log_stack"
        for ((; i > 0; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    fi
    echo "${stack}"
}

function ez_log_error() {
    (>&2 echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZ_BASH_LOG_LOGO}]$(ez_log_stack 1)[ERROR] ${@}")
}

function ez_log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZ_BASH_LOG_LOGO}]$(ez_log_stack 1)[INFO] ${@}"
}

function ez_log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][${EZ_BASH_LOG_LOGO}]$(ez_log_stack 1)[WARNING] ${@}"
}

function ez_print_usage() {
    tabs "${EZ_BASH_TAB_SIZE}" && (>&2 printf "${1}\n") && tabs
}

function ez_build_usage() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        local usage="\n[Function Name]\t\"ez_build_usage\"\n[Function Info]\tEZ-BASH usage builder\n"
        usage+="-o|--operation\tValid operations [\"add\", \"init\"]\n"
        usage+="-a|--argument\tArgument Name\n"
        usage+="-d|--description\tArgument Description\n"
        ez_print_usage "${usage}"
        return
    fi
    local operation=""; local argument=""; local description="No Description"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-o" | "--operation") shift; operation=${1} && [ -n "${1}" ] && shift ;;
            "-a" | "--argument") shift; argument=${1} && [ -n "${1}" ] && shift ;;
            "-d" | "--description") shift; description=${1} && [ -n "${1}" ] && shift ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    case "${operation}" in
        "init")
            [ -z "${argument}" ] && argument="${FUNCNAME[1]}"
            echo "\n[Function Name]\t\"${argument}\"\n[Function Info]\t${description}\n" ;;
        "add")
            echo "${argument}\t${description}\n" ;;
        *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
    esac
}

function ez_source() {
    [ -z "${1}" ] && ez_log_error "Empty file path" && return 1
    local file_path="${1}"
    [ ! -f "${file_path}" ] && ez_log_error "Invalid file path \"${file_path}\"" && return 2
    [ ! -r "${file_path}" ] && ez_log_error "Unreadable file \"${file_path}\"" && return 3
    if ! source "${file_path}"; then ez_log_error "Failed to source \"${file_path}\"" && return 4; fi
}

function ez_source_directory() {
    if [ "${1}" = "" -o "${1}" = "-h" -o "${1}" = "--help" ]; then
        local usage=$(ez_build_usage -o "init" -d "Source Directory")
        usage+=$(ez_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
        usage+=$(ez_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
        ez_print_usage "${usage}"
        return
    fi
    local path="."; local exclude=""
    while [ -n "${1}" ]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1} && [ -n "${1}" ] && shift ;;
            "-r" | "--exclude") shift; exclude=${1} && [ -n "${1}" ] && shift ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [ -z "${path}" ] && ez_log_error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    [ ! -d "${path}" ] && ez_log_error "\"${path}\" is not a directory" && return 2
    [ ! -r "${path}" ] && ez_log_error "Cannot read directory \"${dir_path}\"" && return 3
    if [ "${exclude}" = "" ]; then
        for sh_file_path in $(find "${path}" -type f -name '*.sh'); do
            if ! ez_source "${sh_file_path}"; then return 4; fi
        done
    else
        for sh_file_path in $(find "${path}" -type f -name '*.sh' | grep -v "${exclude}"); do
            if ! ez_source "${sh_file_path}"; then return 4; fi
        done
    fi
}
