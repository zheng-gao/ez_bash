###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_BOOL_TRUE="True"
EZB_BOOL_FALSE="False"
EZB_OPT_ALL="All"
EZB_OPT_ANY="Any"
EZB_OPT_NONE="None"
EZB_CHAR_SHARP="EZB_SHARP"
EZB_CHAR_SPACE="EZB_SPACE"
EZB_CHAR_NON_SPACE_DELIMITER="#"
EZB_DIR_WORKSPACE="/var/tmp/ezb_workspace"; mkdir -p "${EZB_DIR_WORKSPACE}"
EZB_DIR_SCRIPTS="${EZB_DIR_WORKSPACE}/scripts"; mkdir -p "${EZB_DIR_SCRIPTS}"
EZB_DIR_LOGS="${EZB_DIR_WORKSPACE}/logs"; mkdir -p "${EZB_DIR_LOGS}"
EZB_DIR_DATA="${EZB_DIR_WORKSPACE}/data"; mkdir -p "${EZB_DIR_DATA}"
EZB_DEFAULT_LOG="${EZB_DIR_LOGS}/ez_bash.log"

EZB_FUNC_HELP="--help"
EZB_ARG_TYPE_DEFAULT="String"

# Source this file should clean all these global accociative arrays
unset EZB_DEPENDENCY_SET;                        declare -g -A EZB_DEPENDENCY_SET

# EZ-Bash Function Maps
unset EZB_ARG_TYPE_SET
declare -g -A EZB_ARG_TYPE_SET=(
    ["${EZB_ARG_TYPE_DEFAULT}"]="${EZB_BOOL_TRUE}"
    ["List"]="${EZB_BOOL_TRUE}"
    ["Flag"]="${EZB_BOOL_TRUE}"
    ["Password"]="${EZB_BOOL_TRUE}"
)
unset EZB_FUNC_SET;                              declare -g -A EZB_FUNC_SET
# Key Format: function, Value Format: arg1#arg2#...
unset EZB_FUNC_TO_S_ARG_MAP;                     declare -g -A EZB_FUNC_TO_S_ARG_MAP
unset EZB_FUNC_TO_L_ARG_MAP;                     declare -g -A EZB_FUNC_TO_L_ARG_MAP
# Key Format: function + "::" + long name
unset EZB_L_ARG_SET;                             declare -g -A EZB_L_ARG_SET
unset EZB_L_ARG_TO_S_ARG_MAP;                    declare -g -A EZB_L_ARG_TO_S_ARG_MAP
unset EZB_L_ARG_TO_TYPE_MAP;                     declare -g -A EZB_L_ARG_TO_TYPE_MAP
unset EZB_L_ARG_TO_REQUIRED_MAP;                 declare -g -A EZB_L_ARG_TO_REQUIRED_MAP
unset EZB_L_ARG_TO_DEFAULT_MAP;                  declare -g -A EZB_L_ARG_TO_DEFAULT_MAP
unset EZB_L_ARG_TO_INFO_MAP;                     declare -g -A EZB_L_ARG_TO_INFO_MAP
unset EZB_L_ARG_TO_CHOICES_MAP;                  declare -g -A EZB_L_ARG_TO_CHOICES_MAP
unset EZB_L_ARG_TO_EXCLUDE_MAP;                  declare -g -A EZB_L_ARG_TO_EXCLUDE_MAP
# Key Format: function + "::" + short name
unset EZB_S_ARG_SET;                             declare -g -A EZB_S_ARG_SET
unset EZB_S_ARG_TO_L_ARG_MAP;                    declare -g -A EZB_S_ARG_TO_L_ARG_MAP
unset EZB_S_ARG_TO_TYPE_MAP;                     declare -g -A EZB_S_ARG_TO_TYPE_MAP
unset EZB_S_ARG_TO_REQUIRED_MAP;                 declare -g -A EZB_S_ARG_TO_REQUIRED_MAP
unset EZB_S_ARG_TO_DEFAULT_MAP;                  declare -g -A EZB_S_ARG_TO_DEFAULT_MAP
unset EZB_S_ARG_TO_INFO_MAP;                     declare -g -A EZB_S_ARG_TO_INFO_MAP
unset EZB_S_ARG_TO_CHOICES_MAP;                  declare -g -A EZB_S_ARG_TO_CHOICES_MAP
unset EZB_S_ARG_TO_EXCLUDE_MAP;                  declare -g -A EZB_S_ARG_TO_EXCLUDE_MAP

###################################################################################################
# ------------------------------------- EZ-Bash Debug Tools ------------------------------------- #
###################################################################################################
function ezb_show_checked_dependencies {
    local dependency; for dependency in "${!EZB_DEPENDENCY_SET[@]}"; do echo "${dependency}"; done
}

function ezb_show_registered_functions {
    local function; for function in "${!EZB_FUNC_SET[@]}"; do echo "${function}"; done
}

###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
function ezb_dependency_check {
    local cmd; for cmd in "${@}"; do
        if [[ -z "${EZB_DEPENDENCY_SET[${cmd}]}" ]]; then
            ezb_command_check "${cmd}" || { ezb_log_error "Command \"${cmd}\" not found"; return 1; }
            EZB_DEPENDENCY_SET["${cmd}"]="${EZB_BOOL_TRUE}"
        fi
    done
}

###################################################################################################
# ----------------------------------- EZ Bash Function Tools ------------------------------------ #
###################################################################################################
function ezb_print_usage { echo; printf "${1}\n" | column -s "#" -t; echo; }

function ezb_build_usage {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        # column delimiter = "#"
        local usage="[Function Name]#ezb_build_usage#\n[Function Info]#EZ-BASH usage builder\n"
        usage+="-o|--operation#Choose from: [\"add\", \"init\"]\n"
        usage+="-a|--argument#Argument Name\n"
        usage+="-d|--description#Argument Description\n"
        ezb_print_usage "${usage}" && return 0
    fi
    local operation="" argument="" description="No Description"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-o" | "--operation") shift; operation=${1}; shift ;;
            "-a" | "--argument") shift; argument=${1}; shift ;;
            "-d" | "--description") shift; description=${1}; shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
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
        *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
    esac
}

function ezb_source_dir {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "Source whole directory")
        usage+=$(ezb_build_usage -o "add" -a "-p|--path" -d "Directory Path, default = \".\"")
        usage+=$(ezb_build_usage -o "add" -a "-d|--depth" -d "Directory Search Depth, default = None")
        usage+=$(ezb_build_usage -o "add" -a "-e|--exclude" -d "Exclude Regex")
        ezb_print_usage "${usage}" && return 0
    fi
    local path="." exclude="" depth=""
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1}; shift ;;
            "-d" | "--depth") shift; depth=${1}; shift ;;
            "-e" | "--exclude") shift; exclude=${1}; shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${path}" ]] && ezb_log_error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    [[ ! -d "${path}" ]] && ezb_log_error "\"${path}\" is not a directory" && return 2
    [[ ! -r "${path}" ]] && ezb_log_error "Cannot read directory \"${dir_path}\"" && return 3
    [[ -n "${depth}" ]] && depth="-depth ${depth}"
    if [[ -z "${exclude}" ]]; then
        local sh_file; for sh_file in $(find "${path}" -type f -name "*.sh" ${depth}); do
            if ! source "${sh_file}"; then ezb_log_error "Failed to source \"${sh_file}\"" && return 4; fi
        done
    else
        local sh_file; for sh_file in $(find "${path}" -type f -name "*.sh" ${depth} | grep -v "${exclude}"); do
            if ! source "${sh_file}"; then ezb_log_error "Failed to source \"${sh_file}\"" && return 4; fi
        done
    fi
}

function ezb_log {
    local valid_output_to=("Console" "File" "${EZB_OPT_ALL}")
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local valid_output_to_str="$(ezb_join ', ' ${valid_output_to[@]})"
        local usage=$(ezb_build_usage -o "init" -d "Print log to file in \"EZ-BASH\" standard log format")
        usage+=$(ezb_build_usage -o "add" -a "-l|--logger" -d "Logger type, default = \"INFO\"")
        usage+=$(ezb_build_usage -o "add" -a "-f|--file" -d "Log file path, default = \"${EZB_DEFAULT_LOG}\"")
        usage+=$(ezb_build_usage -o "add" -a "-m|--message" -d "The message to print")
        usage+=$(ezb_build_usage -o "add" -a "-s|--stack" -d "Hide top x function from stack, default = 1")
        usage+=$(ezb_build_usage -o "add" -a "-o|--output-to" -d "Choose from: [${valid_output_to_str}], default = \"Console\"")
        ezb_print_usage "${usage}" && return 0
    fi
    declare -A arg_set_of_ezb_log_to_file=(
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
                    [[ -n "${arg_set_of_ezb_log_to_file["${1}"]}" ]] && break
                    message+=("${1}"); shift
                done ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    if ezb_excludes "${output_to}" "${valid_output_to[@]}"; then
        local valid_output_to_str="$(ezb_join ', ' ${valid_output_to[@]})"
        ezb_log_error "Invalid value \"${output_to}\" for \"-o|--output-to\", please choose from [${valid_output_to_str}]"
        return 2
    fi
    if [[ "${output_to}" = "Console" ]] || [[ "${output_to}" = "${EZB_OPT_ALL}" ]]; then
        if [[ "$(ezb_lower ${logger})" = "error" ]]; then
            (>&2 echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack ${stack})[$(ezb_string_format ForegroundRed ${logger})] ${message[@]}")
        elif [[ "$(ezb_lower ${logger})" = "warning" ]]; then
            echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack ${stack})[$(ezb_string_format ForegroundYellow ${logger})] ${message[@]}"
        else
            echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack ${stack})[${logger}] ${message[@]}"
        fi
    fi
    if [[ "${output_to}" = "File" ]] || [[ "${output_to}" = "${EZB_OPT_ALL}" ]]; then
        [[ -z "${file}" ]] && file="${EZB_DEFAULT_LOG}"
        # Make sure the log_file exists and you have the write permission
        [[ ! -e "${file}" ]] && touch "${file}"
        [[ ! -f "${file}" ]] && ez_log_error "Log File \"${file}\" not exist" && return 3
        [[ ! -w "${file}" ]] && ez_log_error "Log File \"${file}\" not writable" && return 3
        echo "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack ${stack})[${logger}] ${message[@]}" >> "${file}"
    fi
}

###################################################################################################
# ------------------------------- EZ-Bash Function Argument Parser ------------------------------ #
###################################################################################################
function ezb_function_get_short_arguments {
    sed "s/${EZB_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZB_FUNC_TO_S_ARG_MAP[${1}]}"
}

function ezb_function_get_long_arguments {
    sed "s/${EZB_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZB_FUNC_TO_L_ARG_MAP[${1}]}"
}

function ezb_function_get_list {
    local -n ezb_function_get_list_arg_reference="${1}"
    ezb_split "ezb_function_get_list_arg_reference" "${EZB_CHAR_NON_SPACE_DELIMITER}" "${@:2}"
}

function ezb_function_unregistered {
    # Should only be called by another function. If not, give the function name in 1st argument
    if [[ -z "${1}" ]]; then [[ -z "${EZB_FUNC_SET[${FUNCNAME[1]}]}" ]] && return 0
    else [[ -z "${EZB_FUNC_SET[${1}]}" ]] && return 0; fi
    return 1
}

function ezb_function_check_help_keyword {
    [[ -z "${1}" ]] && return 0 # Print help info if no argument given
    ezb_excludes "${EZB_FUNC_HELP}" "${@}" && return 1 || return 0
}

function ezb_function_print_help {
    if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "Print Function Help")
        usage+=$(ezb_build_usage -o "add" -a "-f|--function" -d "Function Name")
        ezb_print_usage "${usage}" && return 0
    fi
    # Should only be called by another function
    local function="${FUNCNAME[1]}"
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; [[ -n "${1}" ]] && shift ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    [[ -z "${EZB_FUNC_SET[${function}]}" ]] && ezb_log_error "Function \"${function}\" NOT registered" && return 2
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    echo; echo "[Function Name] \"${function}\""; echo
    {
        echo $(ezb_join "${delimiter}" "[Short]" "[Long]" "[Type]" "[Required]" "[Exclude]" "[Default]" "[Choices]" "[Description]")
        local key type required exclude choices default info
        local short; for short in $(ezb_function_get_short_arguments "${function}"); do
            key="${function}${delimiter}${short}"
            long="${EZB_S_ARG_TO_L_ARG_MAP[${key}]}"; [[ -z "${long}" ]] && long="${EZB_OPT_NONE}"
            type="${EZB_S_ARG_TO_TYPE_MAP[${key}]}"; [[ -z "${type}" ]] && type="${EZB_OPT_NONE}"
            required="${EZB_S_ARG_TO_REQUIRED_MAP[${key}]}"; [[ -z "${required}" ]] && required="${EZB_OPT_NONE}"
            exclude="${EZB_S_ARG_TO_EXCLUDE_MAP[${key}]}"; [[ -z "${exclude}" ]] && exclude="${EZB_OPT_NONE}"
            choices="${EZB_S_ARG_TO_CHOICES_MAP[${key}]}"
            [[ -z "${choices}" ]] && choices="${EZB_OPT_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZB_S_ARG_TO_DEFAULT_MAP["${key}"]}"
            [[ -z "${default}" ]] && default="${EZB_OPT_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZB_S_ARG_TO_INFO_MAP["${key}"]}"; [ -z "${info}" ] && info="${EZB_OPT_NONE}"
            echo $(ezb_join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")
        done
        local long; for long in $(ezb_function_get_long_arguments "${function}"); do
            key="${function}${delimiter}${long}"
            short="${EZB_L_ARG_TO_S_ARG_MAP[${key}]}"
            type="${EZB_L_ARG_TO_TYPE_MAP[${key}]}"; [[ -z "${type}" ]] && type="${EZB_OPT_NONE}"
            required="${EZB_L_ARG_TO_REQUIRED_MAP[${key}]}"; [[ -z "${required}" ]] && required="${EZB_OPT_NONE}"
            exclude="${EZB_L_ARG_TO_EXCLUDE_MAP[${key}]}"; [[ -z "${exclude}" ]] && exclude="${EZB_OPT_NONE}"
            choices="${EZB_L_ARG_TO_CHOICES_MAP[${key}]}"
            [[ -z "${choices}" ]] && choices="${EZB_OPT_NONE}" || choices=$(sed "s/${delimiter}/, /g" <<< "${choices}")
            default="${EZB_L_ARG_TO_DEFAULT_MAP["${key}"]}"
            [[ -z "${default}" ]] && default="${EZB_OPT_NONE}" || default=$(sed "s/${delimiter}/, /g" <<< "${default}")
            info="${EZB_L_ARG_TO_INFO_MAP["${key}"]}"; [[ -z "${info}" ]] && info="${EZB_OPT_NONE}"
            if [[ -z "${short}" ]]; then
                short="${EZB_OPT_NONE}"
                echo $(ezb_join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")
            fi
        done
    } | column -t -s "${delimiter}"; echo
}

function ezb_function_usage {
    # By default it will print the "help" when no argument is given
    [[ "${1}" = "--run-with-no-argument" ]] && [[ -z "${2}" ]] && return 1
    ezb_function_check_help_keyword "${@}" && ezb_function_print_help -f "${FUNCNAME[1]}" && return 0 || return 1
}

function ezb_arg_set {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local type_info="[$(ezb_join ', ' ${!EZB_ARG_TYPE_SET[@]})], default = \"${EZB_ARG_TYPE_DEFAULT}\""
        local usage=$(ezb_build_usage -o "init" -d "Register Function Argument")
        usage+=$(ezb_build_usage -o "add" -a "-f|--function" -d "Function Name")
        usage+=$(ezb_build_usage -o "add" -a "-t|--type" -d "Choose from: ${type_info}")
        usage+=$(ezb_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-r|--required" -d "Flag for required argument")
        usage+=$(ezb_build_usage -o "add" -a "-e|--exclude" -d "Mutually exclude other argument")
        usage+=$(ezb_build_usage -o "add" -a "-d|--default" -d "Default Value")
        usage+=$(ezb_build_usage -o "add" -a "-c|--choices" -d "Choices for the argument")
        usage+=$(ezb_build_usage -o "add" -a "-i|--info" -d "Argument Description")
        ezb_print_usage "${usage}" && return 0
    fi
    declare -A arg_set_of_ezb_arg_set=(
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
    local function short long exclude info type="${EZB_ARG_TYPE_DEFAULT}" required="${EZB_BOOL_FALSE}"
    local default=() choices=()
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; shift ;;
            "-t" | "--type") shift; type=${1}; shift ;;
            "-s" | "--short") shift; short=${1}; shift ;;
            "-l" | "--long") shift; long=${1}; shift ;;
            "-e" | "--exclude") shift; exclude=${1}; shift ;;
            "-i" | "--info") shift; info=${1}; shift ;;
            "-r" | "--required") shift; required="${EZB_BOOL_TRUE}" ;;
            "-d" | "--default") shift
                while [[ -n "${1}" ]]; do
                    [[ -n "${arg_set_of_ezb_arg_set["${1}"]}" ]] && break
                    default+=("${1}"); shift
                done ;;
            "-c" | "--choices") shift
                while [[ -n "${1}" ]]; do
                    [[ -n "${arg_set_of_ezb_arg_set["${1}"]}" ]] && break
                    choices+=("${1}"); shift
                done ;;
            *) ezb_log_error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for more info"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    [[ -z "${short}" ]] && [[ -z "${long}" ]] && ezb_log_error "\"-s|--short\" and \"-l|--long\" are None" && return 1
    if [[ -z "${EZB_ARG_TYPE_SET[${type}]}" ]]; then
        ezb_log_error "Invalid value \"${type}\" for \"-t|--type\", please choose from [$(ezb_join ', ' ${!EZB_ARG_TYPE_SET[@]})]"
        return 1
    fi
    # EZ_BASH_FUNCTION_HELP="--help" is reserved for ez_bash function help
    [[ "${short}" = "${EZB_FUNC_HELP}" ]] &&
        ezb_log_error "Invalid short argument \"${short}\", which is an EZ-BASH reserved keyword" && return 2
    [[ "${long}" = "${EZB_FUNC_HELP}" ]] &&
        ezb_log_error "Invalid long argument \"${long}\", which is an EZ-BASH reserved keyword" && return 2
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    # If the key has already been registered, then skip
    if [[ -n "${short}" ]] && [[ -n "${long}" ]]; then
        [[ -n "${EZB_S_ARG_SET[${function}${delimiter}${short}]}" ]] &&
        [[ -n "${EZB_L_ARG_SET[${function}${delimiter}${long}]}" ]] && return
    elif [[ -n "${short}" ]]; then [[ -n "${EZB_S_ARG_SET[${function}${delimiter}${short}]}" ]] && return
    else [[ -n "${EZB_L_ARG_SET[${function}${delimiter}${long}]}" ]] && return; fi
    # Register Function
    EZB_FUNC_SET["${function}"]="${EZB_BOOL_TRUE}"
    local key=""
    if [ -n "${short}" ]; then
        key="${function}${delimiter}${short}"; EZB_S_ARG_SET["${key}"]="${EZB_BOOL_TRUE}"
        if [[ -z "${EZB_FUNC_TO_S_ARG_MAP[${function}]}" ]]; then EZB_FUNC_TO_S_ARG_MAP["${function}"]="${short}"
        else [[ -z "${EZB_S_ARG_TO_TYPE_MAP[${key}]}" ]] && EZB_FUNC_TO_S_ARG_MAP["${function}"]+="${delimiter}${short}"; fi
        EZB_S_ARG_TO_L_ARG_MAP["${key}"]="${long}"
        EZB_S_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZB_S_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZB_S_ARG_TO_EXCLUDE_MAP["${key}"]="${exclude}"
        EZB_S_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZB_S_ARG_TO_DEFAULT_MAP["${key}"]="$(ezb_join "${delimiter}" "${default[@]}")"
        EZB_S_ARG_TO_CHOICES_MAP["${key}"]="$(ezb_join "${delimiter}" "${choices[@]}")"
    else
        key="${function}${delimiter}${long}"; local short_old="${EZB_L_ARG_TO_S_ARG_MAP[${key}]}"
        if [ -n "${short_old}" ]; then
            key="${function}${delimiter}${short_old}"
            # Delete short_old
            unset EZB_S_ARG_TO_L_ARG_MAP["${key}"]
            unset EZB_S_ARG_TO_TYPE_MAP["${key}"]
            unset EZB_S_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZB_S_ARG_TO_EXCLUDE_MAP["${key}"]
            unset EZB_S_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZB_S_ARG_TO_INFO_MAP["${key}"]
            unset EZB_S_ARG_TO_CHOICES_MAP["${key}"]
            unset EZB_S_ARG_SET["${key}"]
            local new_short_list_string=""
            local existing_short; for existing_short in $(ezb_function_get_short_arguments "${function}"); do
                if [[ "${short_old}" != "${existing_short}" ]]; then
                    if [[ -z "${new_short_list_string}" ]]; then new_short_list_string="${existing_short}"
                    else new_short_list_string+="${delimiter}${existing_short}"; fi
                fi
            done
            EZB_FUNC_TO_S_ARG_MAP["${function}"]="${new_short_list_string}"
        fi
    fi
    if [[ -n "${long}" ]]; then
        key="${function}${delimiter}${long}"
        EZB_L_ARG_SET["${key}"]="${EZB_BOOL_TRUE}"
        if [[ -z "${EZB_FUNC_TO_L_ARG_MAP[${function}]}" ]]; then EZB_FUNC_TO_L_ARG_MAP["${function}"]="${long}"
        else [[ -z "${EZB_L_ARG_TO_TYPE_MAP[${key}]}" ]] && EZB_FUNC_TO_L_ARG_MAP["${function}"]+="${delimiter}${long}"; fi
        EZB_L_ARG_TO_S_ARG_MAP["${key}"]="${short}"
        EZB_L_ARG_TO_TYPE_MAP["${key}"]="${type}"
        EZB_L_ARG_TO_REQUIRED_MAP["${key}"]="${required}"
        EZB_L_ARG_TO_EXCLUDE_MAP["${key}"]="${exclude}"
        EZB_L_ARG_TO_INFO_MAP["${key}"]="${info}"
        EZB_L_ARG_TO_DEFAULT_MAP["${key}"]="$(ezb_join "${delimiter}" "${default[@]}")"
        EZB_L_ARG_TO_CHOICES_MAP["${key}"]="$(ezb_join "${delimiter}" "${choices[@]}")"
    else
        key="${function}${delimiter}${short}"; local long_old="${EZB_S_ARG_TO_L_ARG_MAP[${key}]}"
        if [[ -n "${long_old}" ]]; then
            key="${function}${delimiter}${long_old}"
            # Delete long_old
            unset EZB_L_ARG_TO_S_ARG_MAP["${key}"]
            unset EZB_L_ARG_TO_TYPE_MAP["${key}"]
            unset EZB_L_ARG_TO_REQUIRED_MAP["${key}"]
            unset EZB_L_ARG_TO_EXCLUDE_MAP["${key}"]
            unset EZB_L_ARG_TO_DEFAULT_MAP["${key}"]
            unset EZB_L_ARG_TO_INFO_MAP["${key}"]
            unset EZB_L_ARG_TO_CHOICES_MAP["${key}"]
            unset EZB_L_ARG_SET["${key}"]
            local new_long_list_string=""
            local existing_long; for existing_long in $(ezb_function_get_long_arguments "${function}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [[ -z "${new_short_list_string}" ]]; then new_long_list_string="${existing_long}"
                    else new_long_list_string+="${delimiter}${existing_long}"; fi
                fi
            done
            EZB_FUNC_TO_L_ARG_MAP["${function}"]="${new_long_list_string}"
        fi
    fi
}

function ezb_arg_exclude_check {
    local function="${1}" arg_name="${2}" exclude="${3}" arguments=("${@:4}") key x_arg
    declare -A exclude_set
    for x_arg in $(ezb_function_get_short_arguments "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZB_S_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZB_BOOL_TRUE}"
        fi
    done
    for x_arg in $(ezb_function_get_long_arguments "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZB_L_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZB_BOOL_TRUE}"
        fi
    done
    for x_arg in "${arguments[@]}"; do
        if [[ -n "${x_arg}" ]] && [[ "${x_arg}" != "${arg_name}" ]] && [[ -n "${exclude_set[${x_arg}]}" ]]; then
            ezb_log --stack "2" --logger "ERROR" --message "\"${arg_name}\" and \"${x_arg}\" are mutually exclusive in group: ${exclude}"
            return 1
        fi
    done
    return 0
}

function ezb_arg_get {
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        local usage=$(ezb_build_usage -o "init" -d "Get argument value from argument list")
        usage+=$(ezb_build_usage -o "add" -a "-s|--short" -d "Short Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-l|--long" -d "Long Identifier")
        usage+=$(ezb_build_usage -o "add" -a "-a|--arguments" -d "Argument List")
        ezb_print_usage "${usage}"
        echo "[Notes]"
        echo "    Can only be called by another function"
        echo "    The arguments to process must be at the end of this function's argument list"
        echo "[Example]"
        echo "    ${FUNCNAME[0]} -s|--short \${SHORT_ARG} -l|--long \${LONG_ARG} -a|--arguments \"\${@}\""
        echo; return 0
    fi
    # Must Run Inside Other Functions
    local function="${FUNCNAME[1]}" short long arguments=()
    [[ -z "${EZB_FUNC_SET[${function}]}" ]] && ezb_log_error "Function \"${function}\" NOT registered" && return 2
    if [ "${1}" = "-s" -o "${1}" = "--short" ]; then short="${2}"
        if [ "${3}" = "-l" -o "${3}" = "--long" ]; then long="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ezb_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ezb_log_error "Invalid argument identifier \"${3}\", expected \"-l|--long\" or \"-a|--arguments\""
            ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    elif [ "${1}" = "-l" -o "${1}" = "--long" ]; then long="${2}"
        if [ "${3}" = "-s" -o "${3}" = "--short" ]; then short="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ezb_log_error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ezb_log_error "Invalid argument identifier \"${5}\", expected \"-s|--short\" or \"-a|--arguments\""
            ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
        fi
    else
        ezb_log_error "Invalid argument identifier \"${1}\", expected \"-s|--short\" or \"-l|--long\""
        ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    if [[ -z "${short}" ]] && [[ -z "${long}" ]]; then
        ezb_log_error "Not found \"-s|--short\" or \"-l|--long\""
        ezb_log_error "Run \"${FUNCNAME[0]} --help\" for more info"; return 1
    fi
    local short_key long_key
    if [[ -n "${short}" ]]; then
        short_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${short}"
        if [[ -z "${EZB_S_ARG_SET[${short_key}]}" ]]; then
            ezb_log_error "\"${short}\" has NOT been registered as short identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${long}" ]]; then
        long_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${long}"
        if [[ -z "${EZB_L_ARG_SET[${long_key}]}" ]]; then
            ezb_log_error "\"${long}\" has NOT been registered as long identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${short}" ]] && [[ -n "${long}" ]]; then
        # Check short/long pair matches 
        local match_count=0
        [[ "${EZB_L_ARG_TO_S_ARG_MAP[${long_key}]}" = "${short}" ]] && ((++match_count))
        [[ "${EZB_S_ARG_TO_L_ARG_MAP[${short_key}]}" = "${long}" ]] && ((++match_count))
        if [[ "${match_count}" -ne 2 ]]; then
            ezb_log_error "The Arg-Short identifier \"${short}\" and the Arg-Long identifier \"${long}\" Not Match"
            ezb_log_error "Expected: Arg-Short \"${short}\" -> Arg-Long \"${EZB_S_ARG_TO_L_ARG_MAP[${short_key}]}\""
            ezb_log_error "Expected: Arg-Long \"${long}\" -> Arg-Short \"${EZB_L_ARG_TO_S_ARG_MAP[${long_key}]}\""
            return 2
        fi
    fi
    local argument_type=""; local argument_default=""; local argument_choices=""; local argument_exclude=""
    if [[ -n "${short}" ]]; then
        argument_required="${EZB_S_ARG_TO_REQUIRED_MAP[${short_key}]}"
        argument_exclude="${EZB_S_ARG_TO_EXCLUDE_MAP[${short_key}]}"
        argument_type="${EZB_S_ARG_TO_TYPE_MAP[${short_key}]}"
        argument_default="${EZB_S_ARG_TO_DEFAULT_MAP[${short_key}]}"
        argument_choices="${EZB_S_ARG_TO_CHOICES_MAP[${short_key}]}"
    else
        argument_required="${EZB_L_ARG_TO_REQUIRED_MAP[${long_key}]}"
        argument_exclude="${EZB_L_ARG_TO_EXCLUDE_MAP[${long_key}]}"
        argument_type="${EZB_L_ARG_TO_TYPE_MAP[${long_key}]}"
        argument_default="${EZB_L_ARG_TO_DEFAULT_MAP[${long_key}]}"
        argument_choices="${EZB_L_ARG_TO_CHOICES_MAP[${long_key}]}"   
    fi
    local delimiter="${EZB_CHAR_NON_SPACE_DELIMITER}"
    if [[ -z "${argument_type}" ]]; then
        [[ -n "${short}" ]] &&
            ezb_log_error "Arg-Type for argument \"${short}\" of function \"${function}\" Not Found" && return 3
        [[ -n "${long}" ]] &&
            ezb_log_error "Arg-Type for argument \"${long}\" of function \"${function}\" Not Found" && return 3
    fi
    if [[ "${argument_type}" = "Flag" ]]; then
        local item; for item in "${arguments[@]}"; do
            if [[ "${item}" = "${short}" ]] || [[ "${item}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ezb_arg_exclude_check "${function}" "${item}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                echo "${EZB_BOOL_TRUE}"; return 0
            fi
        done
        echo "${EZB_BOOL_FALSE}"; return 0
    elif [[ "${argument_type}" = "String" ]] || [[ "${argument_type}" = "Password" ]]; then
        local i=0; for ((; i < ${#arguments[@]} - 1; ++i)); do
            local argument_name="${arguments[${i}]}" argument_value="${arguments[$((i+1))]}"
            if [[ "${argument_name}" = "${short}" ]] || [[ "${argument_name}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ezb_arg_exclude_check "${function}" "${argument_name}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                if [[ -n "${argument_choices}" ]]; then
                    declare -A choice_set
                    local choice="" length="${#argument_choices}"
                    local last_index=$((length - 1))
                    local k=0; for ((; k < "${length}"; ++k)); do
                        local char="${argument_choices:${k}:1}"
                        if [[ "${char}" = "${delimiter}" ]]; then
                            [[ -n "${choice}" ]] && choice_set["${choice}"]="${EZB_BOOL_TRUE}"
                            choice=""
                        else
                            choice+="${char}"
                        fi
                        [[ "${k}" -eq "${last_index}" ]] && [[ -n "${choice}" ]] && choice_set["${choice}"]="${EZB_BOOL_TRUE}"
                    done
                    if [[ -z "${choice_set[${argument_value}]}" ]]; then
                        local choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ezb_log_error "Invalid value \"${argument_value}\" for \"${argument_name}\", please choose from [${choices_string}]"
                        return 5
                    fi
                fi
                # No Choices Restriction
                echo "${argument_value}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && [[ "${argument_required}" = "${EZB_BOOL_TRUE}" ]]; then
            if [[ "${argument_type}" = "Password" ]]; then
                local ask_for_password=""
                if [[ -n "${long}" ]]; then
                    long_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${long}"
                    read -s -p "${EZB_L_ARG_TO_INFO_MAP[${long_key}]} \"${long}\": " ask_for_password
                    echo "${ask_for_password}"; return 0
                else
                    short_key="${function}${EZB_CHAR_NON_SPACE_DELIMITER}${short}"
                    read -s -p "${EZB_S_ARG_TO_INFO_MAP[${short_key}]} \"${short}\": " ask_for_password
                    echo "${ask_for_password}"; return 0
                fi
            else
                [[ -n "${short}" ]] && ezb_log_error "Argument \"${short}\" is required" && return 6
                [[ -n "${long}" ]] && ezb_log_error "Argument \"${long}\" is required" && return 6
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
                    ezb_arg_exclude_check "${function}" "${arguments[${i}]}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                local output=""; local count=0
                local j=1; for ((; i + j < ${#arguments[@]}; ++j)); do
                    local index=$((i + j))
                    # List ends with another argument identifier or end of line
                    ezb_contains "${arguments[${index}]}" $(ezb_function_get_short_arguments "${function}") && break
                    ezb_contains "${arguments[${index}]}" $(ezb_function_get_long_arguments "${function}") && break
                    [[ "${count}" -eq 0 ]] && output="${arguments[${index}]}" || output+="${delimiter}${arguments[${index}]}"
                    ((++count))
                done
                # [To Do] Return list directly: ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${output}"
                echo "${output}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && [[ "${argument_required}" = "${EZB_BOOL_TRUE}" ]]; then
            [[ -n "${short}" ]] && ezb_log_error "Argument \"${short}\" is required" && return 6
            [[ -n "${long}" ]] && ezb_log_error "Argument \"${long}\" is required" && return 6
        fi
        # Not Found, Use Default
        # [To Do] Return list directly: ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${argument_default}"
        echo "${argument_default}"
    fi
}
