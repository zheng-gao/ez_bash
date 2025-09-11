###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_CHAR_NON_SPACE_DELIMITER="#"
EZ_DIR_WORKSPACE="/var/tmp/ez_workspace"; mkdir -p "${EZ_DIR_WORKSPACE}"
EZ_DIR_SCRIPTS="${EZ_DIR_WORKSPACE}/scripts"; mkdir -p "${EZ_DIR_SCRIPTS}"
EZ_DIR_LOGS="${EZ_DIR_WORKSPACE}/logs"; mkdir -p "${EZ_DIR_LOGS}"
EZ_DIR_DATA="${EZ_DIR_WORKSPACE}/data"; mkdir -p "${EZ_DIR_DATA}"
# shellcheck disable=SC2034
EZ_DEFAULT_LOG="${EZ_DIR_LOGS}/ez_bash.log"

EZ_FUNC_HELP="--help"
EZ_ARG_TYPE_DEFAULT="String"

# Source this file should clean all these global accociative arrays
# EZ-Bash Function Maps
unset EZ_ARG_TYPE_SET
declare -gA EZ_ARG_TYPE_SET=(
    ["${EZ_ARG_TYPE_DEFAULT}"]="${EZ_TRUE}"
    ["List"]="${EZ_TRUE}"
    ["Flag"]="${EZ_TRUE}"
    ["Password"]="${EZ_TRUE}"
)
declare -gA ARG_SET_OF_EZ_ARGUMENT_SET=(
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
function ez.function.show_registered { local function; for function in "${!EZ_FUNC_SET[@]}"; do echo "${function}"; done; }
# ez.function.unregistered  Should only be called by another function. If not, give the function name in 1st argument
function ez.function.unregistered { if [[ -z "${1}" ]]; then test -z "${EZ_FUNC_SET[${FUNCNAME[1]}]}"; else test -z "${EZ_FUNC_SET[${1}]}"; fi; }
function ez.function.help {  # By default it will print the "help" when no argument is given
    if [[ "${*}" = "--run-with-no-argument" ]]; then return 0; fi # No help info and run function if no argument given
    if [[ -z "${*}" ]] || ez.includes "${EZ_FUNC_HELP}" "${@}"; then ez.function.arguments.print -f "${FUNCNAME[1]}"; return 1; fi; return 0
}
function ez.function.arguments.get_short { sed "s/${EZ_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZ_FUNC_TO_S_ARG_MAP[${1}]}"; }
function ez.function.arguments.get_long { sed "s/${EZ_CHAR_NON_SPACE_DELIMITER}/ /g" <<< "${EZ_FUNC_TO_L_ARG_MAP[${1}]}"; }
function ez.function.arguments.get_list {
    local status_code="${?}"; if [[ "${status_code}" -ne 0 ]]; then return "${status_code}"; fi
    # shellcheck disable=SC2034
    local -n ez_function_arguments_get_list_arg_reference="${1}"; ez.split "ez_function_arguments_get_list_arg_reference" "${EZ_CHAR_NON_SPACE_DELIMITER}" "${@:2}"
}
function ez.function.arguments.print {
    local function="${FUNCNAME[1]}"
    [[ "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Print the help info of the target function" \
        -a "-f|--function" -t "String" -d "${function}" -c "" -i "The name of the target function" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; [[ -n "${1}" ]] && shift ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    [[ -z "${function}" ]] && function="${FUNCNAME[1]}"
    [[ -z "${EZ_FUNC_SET[${function}]}" ]] && ez.log.error "Function \"${function}\" NOT registered" && return 2
    local delimiter="${EZ_CHAR_NON_SPACE_DELIMITER}" indent="    "
    echo; echo "${indent}[Function Name] ${function}"; echo
    # shellcheck disable=SC2030
    {
        echo "${indent}$(ez.join "${delimiter}" "[Short]" "[Long]" "[Type]" "[Required]" "[Exclude]" "[Default]" "[Choices]" "[Description]")"
        local key type required exclude choices default info
        local short; for short in $(ez.function.arguments.get_short "${function}"); do
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
            echo "${indent}$(ez.join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")"
        done
        local long; for long in $(ez.function.arguments.get_long "${function}"); do
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
                echo "${indent}$(ez.join "${delimiter}" "${short}" "${long}" "${type}" "${required}" "${exclude}" "${default}" "${choices}" "${info}")"
            fi
        done
    } | column -t -s "${delimiter}"; echo
}

###################################################################################################
# ------------------------------- EZ-Bash Function Argument Parser ------------------------------ #
###################################################################################################
function ez.argument.exclude_check {
    local function="${1}" arg_name="${2}" exclude="${3}" arguments=("${@:4}") key x_arg
    declare -A exclude_set
    for x_arg in $(ez.function.arguments.get_short "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZ_S_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZ_TRUE}"
        fi
    done
    for x_arg in $(ez.function.arguments.get_long "${function}"); do
        if [[ "${x_arg}" != "${arg_name}" ]]; then
            key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${x_arg}"
            [[ "${EZ_L_ARG_TO_EXCLUDE_MAP[${key}]}" = "${exclude}" ]] && exclude_set["${x_arg}"]="${EZ_TRUE}"
        fi
    done
    for x_arg in "${arguments[@]}"; do
        if [[ -n "${x_arg}" ]] && [[ "${x_arg}" != "${arg_name}" ]] && [[ -n "${exclude_set[${x_arg}]}" ]]; then
            ez.log --stack "2" --logger "ERROR" --message "\"${arg_name}\" and \"${x_arg}\" are mutually exclusive in group: ${exclude}"
            return 1
        fi
    done
    return 0
}

function ez.argument.set {
    local function="${FUNCNAME[1]}" short long exclude info type="${EZ_ARG_TYPE_DEFAULT}" required="${EZ_FALSE}" default=() choices=()
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Register Function Argument" \
        -a "-f|--function" -t "String" -d "${function}" -c "" -i "Target Function Name" \
        -a "-t|--type" -t "String" -d "${type}" -c "[$(ez.join ", " "${!EZ_ARG_TYPE_SET[@]}")]" -i "Function Argument Type" \
        -a "-s|--short" -t "String" -d "${short}" -c "" -i "Short Argument Identifier" \
        -a "-l|--long" -t "String" -d "${long}" -c "" -i "Long Argument Identifier" \
        -a "-e|--exclude" -t "String" -d "${exclude}" -c "" -i "Mutually Exclusive Group ID" \
        -a "-i|--info" -t "String" -d "${info}" -c "" -i "Argument Description" \
        -a "-d|--default" -t "List" -d "[$(ez.join ", " "${default[@]}")]" -c "" -i "Argument Default Value" \
        -a "-c|--choices" -t "List" -d "[$(ez.join ", " "${choices[@]}")]" -c "" -i "Argument Value Choices" \
        -a "-r|--required" -t "Flag" -d "" -c "" -i "Required Argument" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-f" | "--function") shift; function=${1}; shift ;;
            "-t" | "--type") shift; type=${1}; shift ;;
            "-s" | "--short") shift; short=${1}; shift ;;
            "-l" | "--long") shift; long=${1}; shift ;;
            "-e" | "--exclude") shift; exclude=${1}; shift ;;
            "-i" | "--info") shift; info=${1}; shift ;;
            "-r" | "--required") shift; required="${EZ_TRUE}" ;;
            "-d" | "--default") shift; while [[ -n "${1}" ]]; do [[ -n "${ARG_SET_OF_EZ_ARGUMENT_SET["${1}"]}" ]] && break; default+=("${1}"); shift; done ;;
            "-c" | "--choices") shift; while [[ -n "${1}" ]]; do [[ -n "${ARG_SET_OF_EZ_ARGUMENT_SET["${1}"]}" ]] && break; choices+=("${1}"); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    [[ -z "${short}" ]] && [[ -z "${long}" ]] && ez.log.error "\"-s|--short\" and \"-l|--long\" are None" && return 1
    if [[ -z "${EZ_ARG_TYPE_SET[${type}]}" ]]; then
        ez.log.error "Invalid value \"${type}\" for \"-t|--type\", please choose from [$(ez.join ', ' "${!EZ_ARG_TYPE_SET[@]}")]"
        return 1
    fi
    # EZ_BASH_FUNCTION_HELP="--help" is reserved for ez_bash function help
    [[ "${short}" = "${EZ_FUNC_HELP}" ]] &&
        ez.log.error "Invalid short argument \"${short}\", which is an EZ-BASH reserved keyword" && return 2
    [[ "${long}" = "${EZ_FUNC_HELP}" ]] &&
        ez.log.error "Invalid long argument \"${long}\", which is an EZ-BASH reserved keyword" && return 2
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
        EZ_S_ARG_TO_DEFAULT_MAP["${key}"]="$(ez.join "${delimiter}" "${default[@]}")"
        EZ_S_ARG_TO_CHOICES_MAP["${key}"]="$(ez.join "${delimiter}" "${choices[@]}")"
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
            local existing_short; for existing_short in $(ez.function.arguments.get_short "${function}"); do
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
        EZ_L_ARG_TO_DEFAULT_MAP["${key}"]="$(ez.join "${delimiter}" "${default[@]}")"
        EZ_L_ARG_TO_CHOICES_MAP["${key}"]="$(ez.join "${delimiter}" "${choices[@]}")"
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
            local existing_long; for existing_long in $(ez.function.arguments.get_long "${function}"); do
                if [[ "${long_old}" != "${existing_long}" ]]; then
                    if [[ -z "${new_short_list_string}" ]]; then new_long_list_string="${existing_long}"
                    else new_long_list_string+="${delimiter}${existing_long}"; fi
                fi
            done
            EZ_FUNC_TO_L_ARG_MAP["${function}"]="${new_long_list_string}"
        fi
    fi
}

function ez.argument.get {
    # Must Run Inside Other Functions
    local function="${FUNCNAME[1]}" short long arguments=()
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Get argument value from argument list" \
        -a "-s|--short" -t "String" -d "${short}" -c "" -i "The name of the argument short identifier" \
        -a "-l|--long" -t "String" -d "${long}" -c "" -i "The name of the argument long identifier" \
        -a "-a|--arguments" -t "List" -d "[$(ez.join ", " "${arguments[@]}")]" -c "" -i "Argument list of the target function" && {
        echo "    [Notes]"
        echo "        Can only be called by another function"
        echo "        The arguments to process must be at the end of this function's argument list"
        echo "    [Example]"
        echo "        ${FUNCNAME[0]} -s|--short \${SHORT_ARG} -l|--long \${LONG_ARG} -a|--arguments \"\${@}\""
        echo
    } && return 0
    [[ -z "${EZ_FUNC_SET[${function}]}" ]] && ez.log.error "Function \"${function}\" NOT registered" && return 2
    if [ "${1}" = "-s" -o "${1}" = "--short" ]; then short="${2}"
        if [ "${3}" = "-l" -o "${3}" = "--long" ]; then long="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ez.log.error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ez.log.error "Invalid argument identifier \"${3}\", expected \"-l|--long\" or \"-a|--arguments\""
            ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
        fi
    elif [ "${1}" = "-l" -o "${1}" = "--long" ]; then long="${2}"
        if [ "${3}" = "-s" -o "${3}" = "--short" ]; then short="${4}"
            if [ "${5}" = "-a" -o "${5}" = "--arguments" ]; then arguments=("${@:6}")
            else
                ez.log.error "Invalid argument identifier \"${5}\", expected \"-a|--arguments\""
                ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
            fi
        elif [ "${3}" = "-a" -o "${3}" = "--arguments" ]; then arguments=("${@:4}")
        else
            ez.log.error "Invalid argument identifier \"${5}\", expected \"-s|--short\" or \"-a|--arguments\""
            ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
        fi
    else
        ez.log.error "Invalid argument identifier \"${1}\", expected \"-s|--short\" or \"-l|--long\""
        ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
    fi
    if [[ -z "${short}" ]] && [[ -z "${long}" ]]; then
        ez.log.error "Not found \"-s|--short\" or \"-l|--long\""
        ez.log.error "Run \"${FUNCNAME[0]} --help\" for details"; return 1
    fi
    local short_key long_key
    if [[ -n "${short}" ]]; then
        short_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${short}"
        if [[ -z "${EZ_S_ARG_SET[${short_key}]}" ]]; then
            ez.log.error "\"${short}\" has NOT been registered as short identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${long}" ]]; then
        long_key="${function}${EZ_CHAR_NON_SPACE_DELIMITER}${long}"
        if [[ -z "${EZ_L_ARG_SET[${long_key}]}" ]]; then
            ez.log.error "\"${long}\" has NOT been registered as long identifier for function \"${function}\""
            return 2
        fi
    fi
    if [[ -n "${short}" ]] && [[ -n "${long}" ]]; then
        # Check short/long pair matches 
        local match_count=0
        [[ "${EZ_L_ARG_TO_S_ARG_MAP[${long_key}]}" = "${short}" ]] && ((++match_count))
        [[ "${EZ_S_ARG_TO_L_ARG_MAP[${short_key}]}" = "${long}" ]] && ((++match_count))
        if [[ "${match_count}" -ne 2 ]]; then
            ez.log.error "The Arg-Short identifier \"${short}\" and the Arg-Long identifier \"${long}\" Not Match"
            ez.log.error "Expected: Arg-Short \"${short}\" -> Arg-Long \"${EZ_S_ARG_TO_L_ARG_MAP[${short_key}]}\""
            ez.log.error "Expected: Arg-Long \"${long}\" -> Arg-Short \"${EZ_L_ARG_TO_S_ARG_MAP[${long_key}]}\""
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
            ez.log.error "Arg-Type for argument \"${short}\" of function \"${function}\" Not Found" && return 3
        [[ -n "${long}" ]] &&
            ez.log.error "Arg-Type for argument \"${long}\" of function \"${function}\" Not Found" && return 3
    fi
    if [[ "${argument_type}" = "Flag" ]]; then
        local item; for item in "${arguments[@]}"; do
            if [[ "${item}" = "${short}" ]] || [[ "${item}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ez.argument.exclude_check "${function}" "${item}" "${argument_exclude}" "${arguments[@]}" || return 4
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
                    ez.argument.exclude_check "${function}" "${argument_name}" "${argument_exclude}" "${arguments[@]}" || return 4
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
                        local choices_string; choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ez.log.error "Invalid value \"${argument_value}\" for \"${argument_name}\", please choose from [${choices_string}]"
                        return 5
                    fi
                fi
                # No Choices Restriction
                echo "${argument_value}"; return
            fi
        done
        # Required but not found and no default
        if [[ -z "${argument_default}" ]] && ez.is_true "${argument_required}"; then
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
                [[ -n "${short}" ]] && ez.log.error "Argument \"${short}\" is required" && return 6
                [[ -n "${long}" ]] && ez.log.error "Argument \"${long}\" is required" && return 6
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
        local i=0 j index list_item list_items=()
        for ((; i < ${#arguments[@]} - 1; ++i)); do
            if [[ "${arguments[${i}]}" = "${short}" ]] || [[ "${arguments[${i}]}" = "${long}" ]]; then
                if [[ -n "${argument_exclude}" ]]; then
                    ez.argument.exclude_check "${function}" "${arguments[${i}]}" "${argument_exclude}" "${arguments[@]}" || return 4
                fi
                j=1; for ((; i + j < ${#arguments[@]}; ++j)); do
                    index=$((i + j))
                    # List ends with another argument identifier or end of line
                    ez.includes "${arguments[${index}]}" $(ez.function.arguments.get_short "${function}") && break
                    ez.includes "${arguments[${index}]}" $(ez.function.arguments.get_long "${function}") && break
                    list_items+=("${arguments[${index}]}")
                done
            fi
        done
        if [[ "${#list_items[@]}" -gt 0 ]]; then
            if [[ -n "${argument_choices}" ]]; then
                local list_choices=(); ez.split "list_choices" "${delimiter}" "${argument_choices}"
                for list_item in "${list_items[@]}"; do
                    if ez.excludes "${list_item}" "${list_choices[@]}"; then
                        local choices_string; choices_string="$(sed "s/${delimiter}/, /g" <<< "${argument_choices}")"
                        ez.log.error "Invalid value \"${list_item}\" for \"${short}|${long}\", please choose from [${choices_string}]"; return 5
                    fi
                done
            fi
            ez.join "${delimiter}" "${list_items[@]}"
        else
            # Required but not found and no default
            if [[ -z "${argument_default}" ]] && ez.is_true "${argument_required}"; then
                [[ -n "${short}" ]] && ez.log.error "Argument \"${short}\" is required" && return 6
                [[ -n "${long}" ]] && ez.log.error "Argument \"${long}\" is required" && return 6
            fi
            echo "${argument_default}"
        fi
    fi
}

