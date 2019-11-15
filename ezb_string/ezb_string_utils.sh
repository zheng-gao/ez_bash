function ezb_string_length() {
    local input_string="${1}"
    echo "${#input_string}"
}

function ezb_string_repeat() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-s" --long "--substring" --required --default "=" --info "Substring to be repeated" &&
        ezb_set_arg --short "-c" --long "--count" --required --default "80" --info "The count of the substrings" || return 1
    fi
    ezb_function_usage "${@}" && return
    local substring; substring="$(ezb_get_arg --short "-s" --long "--substring" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local count; count="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ "${count}" -ge 0 ]]; then
        local line=""; local index=0
        for ((; "${index}" < "${count}"; ++index)); do line+="${substring}"; done
        echo "${line}"
    else
        ezb_log_error "Invalid Count \"${count}\"" && return 1
    fi
}

function ezb_trim_string() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-s" --long "--string" --required --info "The string to be trimmed" &&
        ezb_set_arg --short "-p" --long "--pattern" --required --default "${EZB_CHAR_SPACE}" --info "Substring Pattern" &&
        ezb_set_arg --short "-c" --long "--count" --info "Occurrence of the pattern" &&
        ezb_set_arg --short "-k" --long "--key" --required --default "any" --choices "left" "right" "both" "any" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string; string="$(ezb_get_arg --short "-s" --long "--substring" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pattern; pattern="$(ezb_get_arg --short "-p" --long "--pattern" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local count; count="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local key; key="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ "${pattern}" =  "${EZB_CHAR_SPACE}" ]]; then pattern=" "; fi
    if [[ "${key}" = "any" ]]; then
        echo "${string}" | sed "s/${pattern}//g"
    elif [[ "${key}" = "left" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/^\(${pattern}\)\{1,\}//"
        else echo "${string}" | sed "s/^\(${pattern}\)\{1,${count}\}//"; fi
    elif [[ "${key}" = "right" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/\(${pattern}\)\{1,\}$//"
        else echo "${string}" | sed "s/\(${pattern}\)\{1,${count}\}$//"; fi
    elif [[ "${key}" = "both" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/^\(${pattern}\)\{1,\}//" | sed "s/\(${pattern}\)\{1,\}$//"
        else echo "${string}" | sed "s/^\(${pattern}\)\{1,${count}\}//" | sed "s/\(${pattern}\)\{1,${count}\}$//"; fi
    fi
}

function ezb_string_check() {
    local valid_keys=("contains" "starts" "ends")
    local valid_keys_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_keys[@]}")
    local usage_string=$(ezb_build_usage -o "init" -d "Check if given string conforms the given pattern")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--string" -d "The input string")
    usage_string+=$(ezb_build_usage -o "add" -a "-p|--pattern" -d "The input pattern")
    usage_string+=$(ezb_build_usage -o "add" -a "-k|--key" -d "Valid Keys: [${valid_keys_string}]")
    usage_string+=$(ezb_build_usage -o "add" -a "--silent" -d "Hide the output")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local input_string=""
    local pattern=""
    local key=""
    local silent="${EZB_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--string") shift; input_string=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--pattern") shift; pattern=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-k" | "--key") shift; key=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--silent") shift; silent="${EZB_BOOL_TRUE}" ;;
            *) ezb_log_error "Unknown argument \"$1\""; ezb_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if ! ez_argument_check -n "-k|--key" -v "${key}" -c "${valid_keys[@]}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-s|--string" -v "${input_string}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-p|--pattern" -v "${pattern}" -o "${usage_string}"; then return 1; fi
    if [[ "${key}" == "contains" ]]; then
        if [[ "${input_string}" == *"${pattern}"* ]]; then
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
            return 1
        fi
    elif [[ "${key}" == "starts" ]]; then
        if [[ "${input_string}" =~ ^"${pattern}".* ]]; then
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
            return 1
        fi
    elif [[ "${key}" == "ends" ]]; then
        if [[ "${input_string}" =~ .*"${pattern}"$ ]]; then
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
            return 0
        else
            if [[ "${silent}" != "${EZB_BOOL_TRUE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
            return 1
        fi
    fi
}

function ez_print_banner() {
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
        local usage_string=$(ezb_build_usage -o "init" -a "ez_print_banner" -d "Print \"EZ-BASH\" standard banner")
        usage_string+=$(ezb_build_usage -o "add" -a "-s|--substring" -d "The substring in the spliter, default is \"=\"")
        usage_string+=$(ezb_build_usage -o "add" -a "-c|--count" -d "The count of the substrings, default is \"80\"")
        usage_string+=$(ezb_build_usage -o "add" -a "-m|--message" -d "Message to print in the banner")
        usage_string+=$(ezb_build_usage -o "add" -a "-p|--prefix" -d "Print EZ-BASH log prefix")
        ezb_print_usage "${usage_string}"; return 1
    fi
    local count=80
    local substring="="
    local prefix="${EZB_BOOL_FALSE}"
    local message=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--substring") shift; substring="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--count") shift; count="${1-}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--prefix") prefix="${EZB_BOOL_TRUE}"; if [[ ! -z "${1-}" ]]; then shift; fi ;;
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
    local spliter=$(ezb_string_repeat --substring "${substring}" --count ${count})
    if [[ "${prefix}" == "${EZB_BOOL_TRUE}" ]]; then
        ez_print_log -l INFO -m "${spliter}"
        ez_print_log -l INFO -m "${message[@]}"
        ez_print_log -l INFO -m "${spliter}"
    else
        echo "${spliter}"
        echo "${message[@]}"
        echo "${spliter}"
    fi
}
