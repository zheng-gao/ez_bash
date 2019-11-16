function ez_nonempty_check() {
    local usage_string=$(ezb_build_usage -o "init" -d "Check if the variable is non-empty")
    usage_string+=$(ezb_build_usage -o "add" -a "-n|--name" -d "Argument Name")
    usage_string+=$(ezb_build_usage -o "add" -a "-v|--value" -d "Argument Value")
    usage_string+=$(ezb_build_usage -o "add" -a "-o|--output" -d "Output String")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--silent" -d "Hide output")
    usage_string+=$(ezb_build_usage -o "add" -a "-p|--print" -d "Print boolean result")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local name=""
    local value=()
    local output=""
    local silent="${EZB_BOOL_FALSE}"
    local print="${EZB_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]]; then shift
            if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then continue; fi
            if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then continue; fi
            if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then continue; fi
            name="${1-}"; shift
        elif [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]]; then shift
            if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then continue; fi
            if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then continue; fi
            if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then continue; fi
            output="${1-}"; shift
        elif [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then shift; silent="${EZB_BOOL_TRUE}"
        elif [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then shift; print="${EZB_BOOL_TRUE}"
        elif [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then shift
            if [[ "${1-}" == "" ]]; then shift
            else
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]] || [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then break; fi
                    if [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]] || [[ "${1}" == "-s" ]] || [[ "${1}" == "--silent" ]]; then break; fi
                    if [[ "${1}" == "-p" ]] || [[ "${1}" == "--print" ]]; then break; fi
                    value+=("${1-}"); shift
                done
            fi
        else
            ezb_log_error "Unknown argument \"${1}\""
            ezb_print_usage "${usage_string}"; return 1
        fi
    done
    if [[ "${value[@]}" == "" ]]; then
        if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then
            ezb_log_error "\"${name}\" is empty!"
            ezb_print_usage "${output}"
        fi
        if [[ "${print}" == "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
        return 1
    fi
    if [[ "${print}" == "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
}

function ez_argument_check() {
    local all_argument_names=("-n" "--name" "-v" "--value" "-o" "--output" "-c" "--choices")
    local usage_string=$(ezb_build_usage -o "init" -d "Check if the argument option is valid")
    usage_string+=$(ezb_build_usage -o "add" -a "-n|--name" -d "Argument Name")
    usage_string+=$(ezb_build_usage -o "add" -a "-v|--value" -d "Argument Value")
    usage_string+=$(ezb_build_usage -o "add" -a "-o|--output" -d "Output String")
    usage_string+=$(ezb_build_usage -o "add" -a "-c|--choices" -d "Valid Choices")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local name=""
    local value=""
    local output=""
    local choices=()
    while [[ ! -z "${1-}" ]]; do
        if [[ "${1}" == "-n" ]] || [[ "${1}" == "--name" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZB_BOOL_TRUE}" ]]; then name="${1-}"; shift; fi
        elif [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZB_BOOL_TRUE}" ]]; then value="${1-}"; shift; fi
        elif [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]]; then shift
            if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") != "${EZB_BOOL_TRUE}" ]]; then output="${1-}"; shift; fi
        elif [[ "${1}" == "-c" ]] || [[ "${1}" == "--choices" ]]; then shift
            if [[ "${1-}" == "" ]]; then shift
            else
                while [[ ! -z "${1-}" ]]; do
                    if [[ $(ez_check_item_in_array -i "${1-}" -a "${all_argument_names[@]}") == "${EZB_BOOL_TRUE}" ]]; then break; fi
                    choices+=("${1-}"); shift
                done
            fi
        else
            ezb_log_error "Unknown argument \"$1\""
            ezb_print_usage "${usage_string}"; return 1
        fi
    done
    if [[ $(ez_check_item_in_array -i "${value}" -a "${choices[@]}") != "${EZB_BOOL_TRUE}" ]]; then
        ezb_log_error "Invalid value \"${value}\" for \"${name}\""
        ezb_print_usage "${output}"
        return 1
    fi
}

function ez_path_check() {
    local valid_keys=("Nonempty-File" "Directory")
    local valid_keys_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_keys[@]}")
    local usage_string=$(ezb_build_usage -o "init" -d "Check if the given path is a valid file or directory")
    usage_string+=$(ezb_build_usage -o "add" -a "-k|--key" -d "Valid Keys: [${valid_keys_string}], default = \"nonempty-file\"")
    usage_string+=$(ezb_build_usage -o "add" -a "-p|--path" -d "Given Path")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--silent" -d "[Optional][Bool] Does not print error log")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local key=""
    local path=""
    local silent="${EZB_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-k" | "--key") shift; key=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--path") shift; path=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--silent") shift; silent="${EZB_BOOL_TRUE}" ;;
            *) ezb_log_error "Unknown argument \"$1\""; ezb_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_nonempty_check -n "-p|--path" -v "${path}" -o "${usage_string}"; then return 1; fi
    if ! ez_argument_check -n "-k|--key" -v "${key}" -c "${valid_keys[@]}" -o "${usage_string}"; then return 1; fi
    if [[ ! -e "${path}" ]]; then ezb_log_error "${path} does not exist"; return 1; fi
    if [[ "${key}" == "Nonempty-File" ]]; then
        if [[ ! -f "${path}" ]]; then
            if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then ezb_log_error "${path} is not a file"; fi
            return 1
        elif [[ ! -s "${path}" ]]; then
            if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then ezb_log_error "${path} is empty"; fi
            return 1
        fi
    elif [[ "${key}" == "Directory" ]]; then
        if [[ ! -d "${path}" ]]; then
            if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then ezb_log_error "${path} is not a directory"; fi
            return 1
        fi
    fi
    return 0
}


function ezb_sanity_check() {
    local command_list=("date" "uname" "printf")
    for command in "${command_list[@]}"; do
        if ! ezb_cmd_check "${command}"; then
            ezb_log_error "\"${command}\" does not exist!"
        else
            ezb_log_info "\"${command}\" looks good!"
        fi
    done
}