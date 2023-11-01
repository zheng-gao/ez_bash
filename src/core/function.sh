###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_CHAR_SHARP="EZ_SHARP"
EZ_CHAR_SPACE="EZ_SPACE"
EZ_CHAR_NON_SPACE_DELIMITER="#"
EZ_DIR_WORKSPACE="/var/tmp/ez_workspace"; mkdir -p "${EZ_DIR_WORKSPACE}"
EZ_DIR_SCRIPTS="${EZ_DIR_WORKSPACE}/scripts"; mkdir -p "${EZ_DIR_SCRIPTS}"
EZ_DIR_LOGS="${EZ_DIR_WORKSPACE}/logs"; mkdir -p "${EZ_DIR_LOGS}"
EZ_DIR_DATA="${EZ_DIR_WORKSPACE}/data"; mkdir -p "${EZ_DIR_DATA}"
EZ_DEFAULT_LOG="${EZ_DIR_LOGS}/ez_bash.log"

EZ_FUNC_HELP="--help"
EZ_ARG_TYPE_DEFAULT="String"

# Source this file should clean all these global accociative arrays
# EZ-Bash Function Maps
unset EZ_ARG_TYPE_SET
declare -g -A EZ_ARG_TYPE_SET=(
    ["${EZ_ARG_TYPE_DEFAULT}"]="${EZ_TRUE}"
    ["List"]="${EZ_TRUE}"
    ["Flag"]="${EZ_TRUE}"
    ["Password"]="${EZ_TRUE}"
)
unset EZ_FUNC_SET;                              declare -g -A EZ_FUNC_SET
# Key Format: function, Value Format: arg1#arg2#...
unset EZ_FUNC_TO_S_ARG_MAP;                     declare -g -A EZ_FUNC_TO_S_ARG_MAP
unset EZ_FUNC_TO_L_ARG_MAP;                     declare -g -A EZ_FUNC_TO_L_ARG_MAP
# Key Format: function + "::" + long name
unset EZ_L_ARG_SET;                             declare -g -A EZ_L_ARG_SET
unset EZ_L_ARG_TO_S_ARG_MAP;                    declare -g -A EZ_L_ARG_TO_S_ARG_MAP
unset EZ_L_ARG_TO_TYPE_MAP;                     declare -g -A EZ_L_ARG_TO_TYPE_MAP
unset EZ_L_ARG_TO_REQUIRED_MAP;                 declare -g -A EZ_L_ARG_TO_REQUIRED_MAP
unset EZ_L_ARG_TO_DEFAULT_MAP;                  declare -g -A EZ_L_ARG_TO_DEFAULT_MAP
unset EZ_L_ARG_TO_INFO_MAP;                     declare -g -A EZ_L_ARG_TO_INFO_MAP
unset EZ_L_ARG_TO_CHOICES_MAP;                  declare -g -A EZ_L_ARG_TO_CHOICES_MAP
unset EZ_L_ARG_TO_EXCLUDE_MAP;                  declare -g -A EZ_L_ARG_TO_EXCLUDE_MAP
# Key Format: function + "::" + short name
unset EZ_S_ARG_SET;                             declare -g -A EZ_S_ARG_SET
unset EZ_S_ARG_TO_L_ARG_MAP;                    declare -g -A EZ_S_ARG_TO_L_ARG_MAP
unset EZ_S_ARG_TO_TYPE_MAP;                     declare -g -A EZ_S_ARG_TO_TYPE_MAP
unset EZ_S_ARG_TO_REQUIRED_MAP;                 declare -g -A EZ_S_ARG_TO_REQUIRED_MAP
unset EZ_S_ARG_TO_DEFAULT_MAP;                  declare -g -A EZ_S_ARG_TO_DEFAULT_MAP
unset EZ_S_ARG_TO_INFO_MAP;                     declare -g -A EZ_S_ARG_TO_INFO_MAP
unset EZ_S_ARG_TO_CHOICES_MAP;                  declare -g -A EZ_S_ARG_TO_CHOICES_MAP
unset EZ_S_ARG_TO_EXCLUDE_MAP;                  declare -g -A EZ_S_ARG_TO_EXCLUDE_MAP

###################################################################################################
# ----------------------------------- EZ Bash Function Tools ------------------------------------ #
###################################################################################################
function ez_show_registered_functions {
    local function; for function in "${!EZ_FUNC_SET[@]}"; do echo "${function}"; done
}

function ez_print_usage { echo; printf "${1}\n" | column -s "#" -t; echo; }

function ez_build_usage {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        # column delimiter = "#"
        local usage="[Function Name]#ez_build_usage#\n[Function Info]#EZ-BASH usage builder\n"
        usage+="-o|--operation#Choose from: [\"add\", \"init\"]\n"
        usage+="-a|--argument#Argument Name\n"
        usage+="-d|--description#Argument Description\n"
        ez_print_usage "${usage}" && return 0
    fi
    local operation="" argument="" description="No Description"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-o" | "--operation") shift; operation=${1}; shift ;;
            "-a" | "--argument") shift; argument=${1}; shift ;;
            "-d" | "--description") shift; description=${1}; shift ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    # column delimiter = "#"
    case "${operation}" in
        "init")
            [[ -z "${argument}" ]] && argument="${FUNCNAME[1]}"
            echo "[Function Name]#\"${argument}\""
            echo "[Function Info]#${description}\n" ;;
        "add")
            echo "${argument}#${description}\n" ;;
        *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
    esac
}

function ez_source_dir {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ez_build_usage -o "init" -d "Source whole directory")
        usage+=$(ez_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
        usage+=$(ez_build_usage -o "add" -a "-d|--depth" -d "Directory Search Depth, default = None")
        usage+=$(ez_build_usage -o "add" -a "-e|--exclude" -d "Keyword List")
        ez_print_usage "${usage}" && return 0
    fi
    local path="." depth="" exclude=() arg_list=("-p" "--path" "-d" "--depth" "-e" "--exclude")
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1}; shift ;;
            "-d" | "--depth") shift; depth=${1}; shift ;;
            "-e" | "--exclude")
                shift; while [[ -n "${1}" ]] && ez_excludes "${1}" "${arg_list[@]}"; do exclude+=(${1}); shift; done ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${path}" ]] && ez_log_error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    [[ ! -d "${path}" ]] && ez_log_error "\"${path}\" is not a directory" && return 2
    [[ ! -r "${path}" ]] && ez_log_error "Cannot read directory \"${dir_path}\"" && return 3
    [[ -n "${depth}" ]] && depth="-depth ${depth}"
    if [[ -z "${exclude}" ]]; then
        local sh_file; for sh_file in $(find "${path}" -type f -name "*.sh" ${depth}); do
            if ! source "${sh_file}"; then ez_log_error "Failed to source \"${sh_file}\"" && return 4; fi
        done
    else
        local sh_file; for sh_file in $(find "${path}" -type f -name "*.sh" ${depth} | grep -v $(ez_join "\|" "${exclude[@]}")); do
            if ! source "${sh_file}"; then ez_log_error "Failed to source \"${sh_file}\"" && return 4; fi
        done
    fi
}

function ez_log {
    local valid_output_to=("Console" "File" "${EZ_ALL}")
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local valid_output_to_str="$(ez_join ', ' ${valid_output_to[@]})"
        local usage=$(ez_build_usage -o "init" -d "Print log to file in \"EZ-BASH\" standard log format")
        usage+=$(ez_build_usage -o "add" -a "-l|--logger" -d "Logger type, default = \"INFO\"")
        usage+=$(ez_build_usage -o "add" -a "-f|--file" -d "Log file path, default = \"${EZ_DEFAULT_LOG}\"")
        usage+=$(ez_build_usage -o "add" -a "-m|--message" -d "The message to print")
        usage+=$(ez_build_usage -o "add" -a "-s|--stack" -d "Hide top x function from stack, default = 1")
        usage+=$(ez_build_usage -o "add" -a "-o|--output-to" -d "Choose from: [${valid_output_to_str}], default = \"Console\"")
        ez_print_usage "${usage}" && return 0
    fi
    declare -A arg_set_of_ez_log_to_file=(
        ["-l"]="1" ["--logger"]="1" ["-f"]="1" ["--file"]="1" ["-m"]="1" ["--message"]="1"
        ["-s"]="1" ["--stack"]="1" ["-o"]="1" ["--output-to"]="1"
    )
    local logger="INFO"; local file=""; local message=()
    local stack="1"; local output_to="Console"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-l" | "--logger") shift; logger="${1}"; shift ;;
            "-f" | "--file") shift; file="${1}"; shift ;;
            "-o" | "--output-to") shift; output_to="${1}"; shift ;;
            "-s" | "--stack") shift; stack="${1}"; shift ;;
            "-m" | "--message") shift;
                while [[ -n "${1}" ]]; do
                    [[ -n "${arg_set_of_ez_log_to_file["${1}"]}" ]] && break
                    message+=("${1}"); shift
                done ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    if ez_excludes "${output_to}" "${valid_output_to[@]}"; then
        local valid_output_to_str="$(ez_join ', ' ${valid_output_to[@]})"
        ez_log_error "Invalid value \"${output_to}\" for \"-o|--output-to\", please choose from [${valid_output_to_str}]"
        return 2
    fi
    if [[ "${output_to}" = "Console" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        if [[ "$(ez_lower ${logger})" = "error" ]]; then
            (>&2 echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack ${stack})[$(ez_string_format ForegroundRed ${logger})] ${message[@]}")
        elif [[ "$(ez_lower ${logger})" = "warning" ]]; then
            echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack ${stack})[$(ez_string_format ForegroundYellow ${logger})] ${message[@]}"
        else
            echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack ${stack})[${logger}] ${message[@]}"
        fi
    fi
    if [[ "${output_to}" = "File" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        [[ -z "${file}" ]] && file="${EZ_DEFAULT_LOG}"
        # Make sure the log_file exists and you have the write permission
        [[ ! -e "${file}" ]] && touch "${file}"
        [[ ! -f "${file}" ]] && ez_log_error "Log File \"${file}\" not exist" && return 3
        [[ ! -w "${file}" ]] && ez_log_error "Log File \"${file}\" not writable" && return 3
        echo "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack ${stack})[${logger}] ${message[@]}" >> "${file}"
    fi
}

###################################################################################################
# ------------------------------- EZ-Bash Function Argument Parser ------------------------------ #
###################################################################################################
function ez_function_get_short_arguments {
    sed "s/${EZ_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZ_FUNC_TO_S_ARG_MAP[${1}]}"
}

function ez_function_get_long_arguments {
    sed "s/${EZ_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZ_FUNC_TO_L_ARG_MAP[${1}]}"
}

function ez_function_get_list {
    local -n ez_function_get_list_arg_reference="${1}"
    ez_split "ez_function_get_list_arg_reference" "${EZ_CHAR_NON_SPACE_DELIMITER}" "${@:2}"
}

function ez_function_unregistered {
    # Should only be called by another function. If not, give the function name in 1st argument
    if [[ -z "${1}" ]]; then [[ -z "${EZ_FUNC_SET[${FUNCNAME[1]}]}" ]] && return 0
    else [[ -z "${EZ_FUNC_SET[${1}]}" ]] && return 0; fi
    return 1
}

function ez_function_check_help_keyword {
    [[ -z "${1}" ]] && return 0 # Print help info if no argument given
    ez_excludes "${EZ_FUNC_HELP}" "${@}" && return 1 || return 0
}

function ez_function_print_help {
    if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ez_build_usage -o "init" -d "Print Function Help")
        usage+=$(ez_build_usage -o "add" -a "-f|--function" -d "Function Name")
        ez_print_usage "${usage}" && return 0
    fi
    # Should only be called by another function
    local function="${FUNCNAME[1]}"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; [[ -n "${1}" ]] && shift ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    [[ -z "${EZ_FUNC_SET[${function}]}" ]] && ez_log_error "Function \"${function}\" NOT registered" && return 2
    local delimiter="${EZ_CHAR_NON_SPACE_DELIMITER}"
    echo; echo "[Function Name] \"${function}\""; echo
    {
        echo $(ez_join "${delimiter}" "[Short]" "[Long]" "[Type]" "[Required]" "[Exclude]" "[Default]" "[Choices]" "[Description]")
        local key type required exclude choices default info
        local short; for short in $(ez_function_get_short_arguments "${function}"); do
            key="${function}${delimiter}${short}"
            long="${EZ_S_ARG_TO_L_ARG_MAP[${key}]}"; [[ -z "${long}" ]] && long="${EZ_NONE}"
            type="${EZ_S_ARG_TO_TYPE_MAP[${key}]}"; [[ -z "${type}" ]] && type="${EZ_NONE}"
            required="${EZ_S_ARG_TO_REQUIRED_MAP[${key}]}"; [[ -z "${required}" ]] && required="${EZ_NONE}"
            exclude="${EZ_S_ARG_TO_EXCLUDE_MAP[${key}]}"; [[ -z "${exclude}" ]] && exclude="${EZ_NONE}"
            choices="${EZ_S_ARG_TO_CHOICES_MAP[${key}]}"
            [[ -z "${choices}" ]] && choices="${EZ_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZ_S_ARG_TO_DEFAULT_MAP["${key}"]}"
            [[ -z "${default}" ]] && default="${EZ_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZ_S_ARG_TO_INFO_MAP["${key}"]}"; [ -z "${info}" ] && info="${EZ_NONE}"
            echo $(ez_join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")
        done
        local long; for long in $(ez_function_get_long_arguments "${function}"); do
            key="${function}${delimiter}${long}"
            short="${EZ_L_ARG_TO_S_ARG_MAP[${key}]}"
            type="${EZ_L_ARG_TO_TYPE_MAP[${key}]}"; [[ -z "${type}" ]] && type="${EZ_NONE}"
            required="${EZ_L_ARG_TO_REQUIRED_MAP[${key}]}"; [[ -z "${required}" ]] && required="${EZ_NONE}"
            exclude="${EZ_L_ARG_TO_EXCLUDE_MAP[${key}]}"; [[ -z "${exclude}" ]] && exclude="${EZ_NONE}"
            choices="${EZ_L_ARG_TO_CHOICES_MAP[${key}]}"
            [[ -z "${choices}" ]] && choices="${EZ_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZ_L_ARG_TO_DEFAULT_MAP["${key}"]}"
            [[ -z "${default}" ]] && default="${EZ_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZ_L_ARG_TO_INFO_MAP["${key}"]}"; [[ -z "${info}" ]] && info="${EZ_NONE}"
            if [[ -z "${short}" ]]; then
                short="${EZ_NONE}"
                echo $(ez_join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")
            fi
        done
    } | column -t -s "${delimiter}"; echo
}

function ez_function_usage {
    # By default it will print the "help" when no argument is given
    [[ "${1}" = "--run-with-no-argument" ]] && [[ -z "${2}" ]] && return 1
    ez_function_check_help_keyword "${@}" && ez_function_print_help -f "${FUNCNAME[1]}" && return 0 || return 1
}

function ez_arg_set {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local type_info="[$(ez_join ', ' ${!EZ_ARG_TYPE_SET[@]})], default = \"${EZ_ARG_TYPE_DEFAULT}\""
        local usage=$(ez_build_usage -o "init" -d "Register Function Argument")
        usage+=$(ez_build_usage -o "add" -a "-f|--function" -d "Function Name")
        usage+=$(ez_build_usage -o "add" -a "-t|--type" -d "Choose from: ${type_info}")
        usage+=$(ez_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ez_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ez_build_usage -o "add" -a "-r|--required" -d "Flag for required argument")
        usage+=$(ez_build_usage -o "add" -a "-e|--exclude" -d "Mutually exclude other argument")
        usage+=$(ez_build_usage -o "add" -a "-d|--default" -d "Default Value")
        usage+=$(ez_build_usage -o "add" -a "-c|--choices" -d "Choices for the argument")
        usage+=$(ez_build_usage -o "add" -a "-i|--info" -d "Argument Description")
        ez_print_usage "${usage}" && return 0
    fi
    declare -A arg_set_of_ez_arg_set=(
        ["-f"]="1" ["--function"]="1"
        ["-t"]="1" ["--type"]="1"
        ["-s"]="1" ["--short"]="1"
        ["-l"]="1" ["--long"]="1"
        ["-r"]="1" ["--required"]="1"
        ["-e"]="1" ["--exclude"]="1"
        ["-d"]="1" ["--default"]="1"
        ["-c"]="1" ["--choices"]="1"
        ["-i"]="1" ["--info"]="1"
    )
    local function short long exclude info type="${EZ_ARG_TYPE_DEFAULT}" required="${EZ_FALSE}"
    local default=() choices=()
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; shift ;;
            "-t" | "--type") shift; type=${1}; shift ;;
            "-s" | "--short") shift; short=${1}; shift ;;
            "-l" | "--long") shift; long=${1}; shift ;;
            "-e" | "--exclude") shift; exclude=${1}; shift ;;
            "-i" | "--info") shift; info=${1}; shift ;;
            "-r" | "--required") shift; required="${EZ_TRUE}" ;;
            "-d" | "--default") shift
                while [[ -n "${1}" ]]; do
                    [[ -n "${arg_set_of_ez_arg_set["${1}"]}" ]] && break
                    default+=("${1}"); shift
                done ;;
            "-c" | "--choices") shift
                while [[ -n "${1}" ]]; do
                    [[ -n "${arg_set_of_ez_arg_set["${1}"]}" ]] && break
                    choices+=("${1}"); shift
                done ;;
            *) ez_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    [[ -z "${short}" ]] && [[ -z "${long}" ]] && ez_log_error "\"-s|--short\" and \"-l|--long\" are None" && return 1
    if [[ -z "${EZ_ARG_TYPE_SET[${type}]}" ]]; then
        ez_log_error "Invalid value \"${type}\" for \"-t|--type\", please choose from [$(ez_join ', ' ${!EZ_ARG_TYPE_SET[@]})]"
        return 1
    fi
    # EZ_BASH_FUNCTION_HELP="--help" is reserved for ez_bash function help
    [[ "${short}" = "${EZ_FUNC_HELP}" ]] &&
        ez_log_error "Invalid short argument \"${short}\", which is an EZ-BASH reserved keyword" && return 2
    [[ "${long}" = "${EZ_FUNC_HELP}" ]] &&
        ez_log_error "Invalid long argument \"${long}\", which is an EZ-BASH reserved keyword" && return 2
    local delimiter="${EZ_CHAR_NON_SPACE_DELIMITER}"
    # If the key has already been registered, then skip
    if [[ -n "${short}" ]] && [[ -n "${long}" ]]; then
        [[ -n "${EZ_S_ARG_SET[${function}${delimiter}${short}]}" ]] &&
        [[ -n "${EZ_L_ARG_SET[${function}${delimiter}${long}]}" ]] && return
    elif [[ -n "${short}" ]]; then [[ -n "${EZ_S_ARG_SET[${function}${delimiter}${short}]}" ]] && return
    else [[ -n "${EZ_L_ARG_SET[${function}${delimiter}${long}]}" ]] && return; fi
    # Register Function
    EZ_FUNC_SET["${function}"]="${EZ_TRUE}"
    local key=""
    if [ -n "${short}" ]; then
        key="${function}${delimiter}${short}"; EZ_S_ARG_SET["${key}"]="${EZ_TRUE}"
        if [[ -z "${EZ_FUNC_TO_S_ARG_MAP[${function}]}" ]]; then EZ_FUNC_TO_S_ARG_MAP["${function}"]="${short}"
        else [[ -z "${EZ_S_ARG_TO_TYPE_MAP[${key}]}" ]] && EZ_FUNC_TO_S_ARG_MAP["${function}"]+="${delimiter}${short}"; fi
        EZ_S_ARG_TO_L_ARG_MAP["${key}"]="${long}"
        EZ_S_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZ_S_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZ_S_ARG_TO_EXCLUDE_MAP["${key}"]="${exclude}"
        EZ_S_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZ_S_ARG_TO_DEFAULT_MAP["${key}"]="$(ez_join "${delimiter}" "${default[@]}")"
        EZ_S_ARG_TO_CHOICES_MAP["${key}"]="$(ez_join "${delimiter}" "${choices[@]}")"
    else
        key="${function}${delimiter}${long}"; local short_old="${EZ_L_ARG_TO_S_ARG_MAP[${key}]}"
        if [ -n "${short_old}" ]; then
            key="${function}${delimiter}${short_old}"
            # Delete short_old
            unset EZ_S_ARG_TO_L_ARG_MAP["${key}"]
            unset EZ_S_ARG_TO_TYPE_MAP["${key}"]
            unset EZ_S_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZ_S_ARG_TO_EXCLUDE_MAP["${key}"]
            unset EZ_S_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZ_S_ARG_TO_INFO_MAP["${key}"]
            unset EZ_S_ARG_TO_CHOICES_MAP["${key}"]
            unset EZ_S_ARG_SET["${key}"]
            local new_short_list_string=""
            local existing_short; for existing_short in $(ez_function_get_short_arguments "${function}"); do
                if [[ "${short_old}" != "${existing_short}" ]]; then
                    if [[ -z "${new_short_list_string}" ]]; then new_short_list_string="${existing_short}"
                    else new_short_list_string+="${delimiter}${existing_short}"; fi
                fi
            done
            EZ_FUNC_TO_S_ARG_MAP["${function}"]="${new_short_list_string}"
        fi
    fi
    if [[ -n "${long}" ]]; then
        key="${function}${delimiter}${long}"
        EZ_L_ARG_SET["${key}"]="${EZ_TRUE}"
        if [[ -z "${EZ_FUNC_TO_L_ARG_MAP[${function}]}" ]]; then EZ_FUNC_TO_L_ARG_MAP["${function}"]="${long}"
        else [[ -z "${EZ_L_ARG_TO_TYPE_MAP[${key}]}" ]] && EZ_FUNC_TO_L_ARG_MAP["${function}"]+="${delimiter}${long}"; fi
        EZ_L_ARG_TO_S_ARG_MAP["${key}"]="${short}"
        EZ_L_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZ_L_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZ_L_ARG_TO_EXCLUDE_MAP["${key}"]="${exclude}"
        EZ_L_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZ_L_ARG_TO_DEFAULT_MAP["${key}"]="$(ez_join "${delimiter}" "${default[@]}")"
        EZ_L_ARG_TO_CHOICES_MAP["${key}"]="$(ez_join "${delimiter}" "${choices[@]}")"
    else
        key="${function}${delimiter}${short}"; local long_old="${EZ_S_ARG_TO_L_ARG_MAP[${key}]}"
        if [[ -n "${long_old}" ]]; then
            key="${function}${delimiter}${long_old}"
            # Delete long_old
            unset EZ_L_ARG_TO_S_ARG_MAP["${key}"]
            unset EZ_L_ARG_TO_TYPE_MAP["${key}"]
            unset EZ_L_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZ_L_ARG_TO_EXCLUDE_MAP["${key}"]
            unset EZ_L_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZ_L_ARG_TO_INFO_MAP["${key}"]
            unset EZ_L_ARG_TO_CHOICES_MAP["${key}"]
            unset EZ_L_ARG_SET["${key}"]
            local new_long_list_string=""
            local existing_long; for existing_long in $(ez_function_get_long_arguments "${function}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [[ -z "${new_short_list_string}" ]]; then new_long_list_string="${existing_long}"
                    else new_long_list_string+="${delimiter}${existing_long}"; fi
                fi
            done
            EZ_FUNC_TO_L_ARG_MAP["${function}"]="${new_long_list_string}"
        fi
    fi
}

function ez_arg_exclude_check {
    local function="${1}" arg_name="${2}" exclude="${3}" arguments=("${@:4}") key x_arg
    declare -A exclude_set
    for x_arg in $(ez_function_get_short_arguments "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZ_S_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZ_TRUE}"
        fi
    done
    for x_arg in $(ez_function_get_long_arguments "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZ_L_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZ_TRUE}"
        fi
    done
    for x_arg in "${arguments[@]}"; do
        if [[ -n "${x_arg}" ]] && [[ "${x_arg}" != "${arg_name}" ]] && [[ -n "${exclude_set[${x_arg}]}" ]]; then
            ez_log --stack "2" --logger "ERROR" --message "\"${arg_name}\" and \"${x_arg}\" are mutually exclusive in group: ${exclude}"
            return 1
        fi
    done
    return 0
}

function ez_arg_get {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ez_build_usage -o "init" -d "Get argument value from argument list")
        usage+=$(ez_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ez_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ez_build_usage -o "add" -a "-a|--arguments" -d "Argument List")
        ez_print_usage "${usage}"
        echo "[Notes]"
        echo "    Can only be called by another function"
        echo "    The arguments to process must be at the end of this function's argument list"
        echo "[Example]"
        echo "    ${FUNCNAME[0]} -s|--short \${SHORT_ARG} -l|--long \${LONG_ARG} -a|--arguments \"\${@}\""
        echo; return 0
    fi
    # Must Run Inside Other Functions
    local function="${FUNCNAME[1]}" short long arguments=()
    [[ -z "${EZ_FUNC_SET[${function}]}" ]] && ez_log_error "Function \"${function}\" NOT registered" && return 2
    if [ "${1}" = "-s" -o "${1}" = "--short" ]; then short="${2}"
        if [ "${3}" = "-l" -o "${3}" = "--long" ]; then long="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ez_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ez_log_error "Invalid argument identifier \"${3}\", expected \"-l|--long\" or \"-a|--arguments\""
            ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    elif [ "${1}" = "-l" -o "${1}" = "--long" ]; then long="${2}"
        if [ "${3}" = "-s" -o "${3}" = "--short" ]; then short="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ez_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ez_log_error "Invalid argument identifier \"${5}\", expected \"-s|--short\" or \"-a|--arguments\""
            ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    else
        ez_log_error "Invalid argument identifier \"${1}\", expected \"-s|--short\" or \"-l|--long\""
        ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    if [[ -z "${short}" ]] && [[ -z "${long}" ]]; then
        ez_log_error "Not found \"-s|--short\" or \"-l|--long\""
        ez_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    local short_key long_key
    if [[ -n "${short}" ]]; then
        short_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${short}"
        if [[ -z "${EZ_S_ARG_SET[${short_key}]}" ]]; then
            ez_log_error "\"${short}\" has NOT been registered as short identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${long}" ]]; then
        long_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${long}"
        if [[ -z "${EZ_L_ARG_SET[${long_key}]}" ]]; then
            ez_log_error "\"${long}\" has NOT been registered as long identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${short}" ]] && [[ -n "${long}" ]]; then
        # Check short/long pair matches 
        local match_count=0
        [[ "${EZ_L_ARG_TO_S_ARG_MAP[${long_key}]}" = "${short}" ]] && ((++match_count))
        [[ "${EZ_S_ARG_TO_L_ARG_MAP[${short_key}]}" = "${long}" ]] && ((++match_count))
        if [[ "${match_count}" -ne 2 ]]; then
            ez_log_error "The Arg-Short identifier \"${short}\" and the Arg-Long identifier \"${long}\" Not Match"
            ez_log_error "Expected: Arg-Short \"${short}\" -> Arg-Long \"${EZ_S_ARG_TO_L_ARG_MAP[${short_key}]}\""
            ez_log_error "Expected: Arg-Long \"${long}\" -> Arg-Short \"${EZ_L_ARG_TO_S_ARG_MAP[${long_key}]}\""
            return 2
        fi
    fi
    local argument_type=""; local argument_default=""; local argument_choices=""; local argument_exclude=""
    if [[ -n "${short}" ]]; then
        argument_required="${EZ_S_ARG_TO_REQUIRED_MAP[${short_key}]}"
        argument_exclude="${EZ_S_ARG_TO_EXCLUDE_MAP[${short_key}]}"
        argument_type="${EZ_S_ARG_TO_TYPE_MAP[${short_key}]}"
        argument_default="${EZ_S_ARG_TO_DEFAULT_MAP[${short_key}]}"
        argument_choices="${EZ_S_ARG_TO_CHOICES_MAP[${short_key}]}"
    else
        argument_required="${EZ_L_ARG_TO_REQUIRED_MAP[${long_key}]}"
        argument_exclude="${EZ_L_ARG_TO_EXCLUDE_MAP[${long_key}]}"
        argument_type="${EZ_L_ARG_TO_TYPE_MAP[${long_key}]}"
        argument_default="${EZ_L_ARG_TO_DEFAULT_MAP[${long_key}]}"
        argument_choices="${EZ_L_ARG_TO_CHOICES_MAP[${long_key}]}"   
    fi
    local delimiter="${EZ_CHAR_NON_SPACE_DELIMITER}"
    if [[ -z "${argument_type}" ]]; then
        [[ -n "${short}" ]] &&
            ez_log_error "Arg-Type for argument \"${short}\" of function \"${function}\" Not Found" && return 3
        [[ -n "${long}" ]] &&
            ez_log_error "Arg-Type for argument \"${long}\" of function \"${function}\" Not Found" && return 3
    fi
    if [[ "${argument_type}" = "Flag" ]]; then
        local item; for item in "${arguments[@]}"; do
            if [[ "${item}" = "${short}" ]] || [[ "${item}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ez_arg_exclude_check "${function}" "${item}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                echo "${EZ_TRUE}"; return 0
            fi
        done
        echo "${EZ_FALSE}"; return 0
    elif [[ "${argument_type}" = "String" ]] || [[ "${argument_type}" = "Password" ]]; then
        local i=0; for ((; i < ${#arguments[@]} - 1; ++i)); do
            local argument_name="${arguments[${i}]}" argument_value="${arguments[$((i+1))]}"
            if [[ "${argument_name}" = "${short}" ]] || [[ "${argument_name}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ez_arg_exclude_check "${function}" "${argument_name}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                if [[ -n "${argument_choices}" ]]; then
                    declare -A choice_set
                    local choice="" length="${#argument_choices}"
                    local last_index=$((length - 1))
                    local k=0; for ((; k < "${length}"; ++k)); do
                        local char="${argument_choices:${k}:1}"
                        if [[ "${char}" = "${delimiter}" ]]; then
                            [[ -n "${choice}" ]] && choice_set["${choice}"]="${EZ_TRUE}"
                            choice=""
                        else
                            choice+="${char}"
                        fi
                        [[ "${k}" -eq "${last_index}" ]] && [[ -n "${choice}" ]] && choice_set["${choice}"]="${EZ_TRUE}"
                    done
                    if [[ -z "${choice_set[${argument_value}]}" ]]; then
                        local choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ez_log_error "Invalid value \"${argument_value}\" for \"${argument_name}\", please choose from [${choices_string}]"
                        return 5
                    fi
                fi
                # No Choices Restriction
                echo "${argument_value}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && ez_is_true "${argument_required}"; then
            if [[ "${argument_type}" = "Password" ]]; then
                local ask_for_password=""
                if [[ -n "${long}" ]]; then
                    long_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${long}"
                    read -s -p "${EZ_L_ARG_TO_INFO_MAP[${long_key}]} \"${long}\": " ask_for_password
                    echo "${ask_for_password}"; return 0
                else
                    short_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${short}"
                    read -s -p "${EZ_S_ARG_TO_INFO_MAP[${short_key}]} \"${short}\": " ask_for_password
                    echo "${ask_for_password}"; return 0
                fi
            else
                [[ -n "${short}" ]] && ez_log_error "Argument \"${short}\" is required" && return 6
                [[ -n "${long}" ]] && ez_log_error "Argument \"${long}\" is required" && return 6
            fi
        fi
        # Not Found, Use Default, Only print the first item in the default list
        local default_value=""; local length="${#argument_default}"
        local last_index=$((length - 1))
        local k=0; for ((; k < "${length}"; ++k)); do
            local char="${argument_default:${k}:1}"
            if [[ "${char}" = "${delimiter}" ]]; then
                [[ -n "${default_value}" ]] && echo "${default_value}"
                return
            else
                default_value+="${char}"
            fi
            [[ "${k}" -eq "${last_index}" ]] && [[ -n "${default_value}" ]] && echo "${default_value}"
        done
    elif [[ "${argument_type}" = "List" ]]; then
        local i=0; for ((; i < ${#arguments[@]} - 1; ++i)); do
            if [[ "${arguments[${i}]}" = "${short}" ]] || [[ "${arguments[${i}]}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ez_arg_exclude_check "${function}" "${arguments[${i}]}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                local output=""; local count=0
                local j=1; for ((; i + j < ${#arguments[@]}; ++j)); do
                    local index=$((i + j))
                    # List ends with another argument identifier or end of line
                    ez_includes "${arguments[${index}]}" $(ez_function_get_short_arguments "${function}") && break
                    ez_includes "${arguments[${index}]}" $(ez_function_get_long_arguments "${function}") && break
                    [[ "${count}" -eq 0 ]] && output="${arguments[${index}]}" || output+="${delimiter}${arguments[${index}]}"
                    ((++count))
                done
                # [To Do] Return list directly: ez_split "${EZ_CHAR_NON_SPACE_DELIMITER}" "${output}"
                echo "${output}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && ez_is_true "${argument_required}"; then
            [[ -n "${short}" ]] && ez_log_error "Argument \"${short}\" is required" && return 6
            [[ -n "${long}" ]] && ez_log_error "Argument \"${long}\" is required" && return 6
        fi
        # Not Found, Use Default
        # [To Do] Return list directly: ez_split "${EZ_CHAR_NON_SPACE_DELIMITER}" "${argument_default}"
        echo "${argument_default}"
    fi
}

