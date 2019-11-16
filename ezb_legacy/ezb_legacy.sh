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
            if ezb_excludes "${1-}" "${all_argument_names[@]}"; then name="${1-}"; shift; fi
        elif [[ "${1}" == "-v" ]] || [[ "${1}" == "--value" ]]; then shift
            if ezb_excludes "${1-}" "${all_argument_names[@]}"; then value="${1-}"; shift; fi
        elif [[ "${1}" == "-o" ]] || [[ "${1}" == "--output" ]]; then shift
            if ezb_excludes "${1-}" "${all_argument_names[@]}"; then output="${1-}"; shift; fi
        elif [[ "${1}" == "-c" ]] || [[ "${1}" == "--choices" ]]; then shift
            if [[ "${1-}" == "" ]]; then shift
            else
                while [[ ! -z "${1-}" ]]; do
                    if ezb_contains "${1-}" "${all_argument_names[@]}"; then break; fi
                    choices+=("${1-}"); shift
                done
            fi
        else
            ezb_log_error "Unknown argument \"$1\""
            ezb_print_usage "${usage_string}"; return 1
        fi
    done
    if ezb_excludes "${value}" "${choices[@]}"; then
        ezb_log_error "Invalid value \"${value}\" for \"${name}\""
        ezb_print_usage "${output}"
        return 1
    fi
}

function ezb_sanity_check() {
    local command_list=("date" "uname" "printf")
    local command=""; for command in "${command_list[@]}"; do
        if ! ezb_cmd_check "${command}"; then
            ezb_log_error "\"${command}\" does not exist!"
        else
            ezb_log_info "\"${command}\" looks good!"
        fi
    done
}