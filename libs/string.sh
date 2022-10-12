###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_string_count_substring() {
    local input_string="${1}" substring="${2}"
    echo "${input_string}" | grep -o "${substring}" | wc -l | bc
}

function ezb_string_repeat() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-s" --long "--string" --required --default "=" --info "String to be repeated" &&
        ezb_arg_set --short "-c" --long "--count" --required --default "80" --info "The count of the substrings" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string && string="$(ezb_arg_get --short "-s" --long "--string" --arguments "${@}")" &&
    local count && count="$(ezb_arg_get --short "-c" --long "--count" --arguments "${@}")" || return 1
    [[ "${count}" -lt 0 ]] && ezb_log_error "Invalid Count \"${count}\"" && return 1
    local line index=0; for ((; "${index}" < "${count}"; ++index)); do line+="${string}"; done; echo "${line}"
}

function ezb_string_trim() {
    if ezb_function_unregistered; then
        local valid_keys=("Left" "Right" "Both" "Any")
        ezb_arg_set --short "-s" --long "--string" --required --info "The string to be trimmed" &&
        ezb_arg_set --short "-p" --long "--pattern" --required --default "${EZB_CHAR_SPACE}" --info "Substring Pattern" &&
        ezb_arg_set --short "-c" --long "--count" --info "Occurrence of the pattern" &&
        ezb_arg_set --short "-k" --long "--key" --required --default "Any" --choices "${valid_keys[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string && string="$(ezb_arg_get --short "-s" --long "--string" --arguments "${@}")" &&
    local pattern && pattern="$(ezb_arg_get --short "-p" --long "--pattern" --arguments "${@}")" &&
    local count && count="$(ezb_arg_get --short "-c" --long "--count" --arguments "${@}")" &&
    local key && key="$(ezb_arg_get --short "-k" --long "--key" --arguments "${@}")" || return 1
    if [[ "${pattern}" =  "${EZB_CHAR_SPACE}" ]]; then pattern=" "; fi
    if [[ "${key}" = "Any" ]]; then echo "${string}" | sed "s/${pattern}//g"
    elif [[ "${key}" = "Left" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/^\(${pattern}\)\{1,\}//"
        else echo "${string}" | sed "s/^\(${pattern}\)\{1,${count}\}//"; fi
    elif [[ "${key}" = "Right" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/\(${pattern}\)\{1,\}$//"
        else echo "${string}" | sed "s/\(${pattern}\)\{1,${count}\}$//"; fi
    elif [[ "${key}" = "Both" ]]; then
        if [[ -z "${count}" ]]; then echo "${string}" | sed "s/^\(${pattern}\)\{1,\}//" | sed "s/\(${pattern}\)\{1,\}$//"
        else echo "${string}" | sed "s/^\(${pattern}\)\{1,${count}\}//" | sed "s/\(${pattern}\)\{1,${count}\}$//"; fi
    fi
}

function ezb_string_cut() {
    if ezb_function_unregistered; then
        local valid_keys=("Left" "Right" "Both")
        ezb_arg_set --short "-s" --long "--string" --required --info "The string to be cut" &&
        ezb_arg_set --short "-l" --long "--length" --info "Length to be cut" &&
        ezb_arg_set --short "-k" --long "--key" --required --default "Left" --choices "${valid_keys[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string && string="$(ezb_arg_get --short "-s" --long "--string" --arguments "${@}")" &&
    local length && length="$(ezb_arg_get --short "-l" --long "--length" --arguments "${@}")" &&
    local key && key="$(ezb_arg_get --short "-k" --long "--key" --arguments "${@}")" || return 1
    case "${key}" in
        "Left") echo "${string:${length}}" ;;
        "Right") echo "${string::-${length}}" ;;
        *) echo "${string:${length}:-${length}}" ;;
    esac
}

function ezb_string_check() {
    if ezb_function_unregistered; then
        local valid_keys=("Contains" "Starts" "Ends")
        ezb_arg_set --short "-s" --long "--string" --required --info "The string to be checked" &&
        ezb_arg_set --short "-p" --long "--pattern" --required --info "Substring Pattern" &&
        ezb_arg_set --short "-k" --long "--key" --required --default "Contains" --choices "${valid_keys[@]}" &&
        ezb_arg_set --short "-v" --long "--verbose" --type "Flag" --info "Print result" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string && string="$(ezb_arg_get --short "-s" --long "--string" --arguments "${@}")" &&
    local pattern && pattern="$(ezb_arg_get --short "-p" --long "--pattern" --arguments "${@}")" &&
    local key && key="$(ezb_arg_get --short "-k" --long "--key" --arguments "${@}")" &&
    local verbose && verbose="$(ezb_arg_get --short "-v" --long "--verbose" --arguments "${@}")" || return 1
    if [[ "${key}" = "Contains" ]]; then
        if [[ "${string}" = *"${pattern}"* ]]; then [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_TRUE}"; return 0
        else [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_FALSE}"; return 2; fi
    elif [[ "${key}" == "Starts" ]]; then
        if [[ "${string}" =~ ^"${pattern}".* ]]; then [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_TRUE}"; return 0
        else [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_FALSE}"; return 2; fi
    elif [[ "${key}" == "Ends" ]]; then
        if [[ "${string}" =~ .*"${pattern}"$ ]]; then [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_TRUE}"; return 0
        else [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_FALSE}"; return 2; fi
    fi
}

function ezb_banner() {
    if ezb_function_unregistered; then
        local valid_keys=("Contains" "Starts" "Ends")
        ezb_arg_set --short "-s" --long "--string" --required --default "=" --info "The string in the line spliter" &&
        ezb_arg_set --short "-c" --long "--count" --required --default "80" --info "The number of the strings in the line spliter" &&
        ezb_arg_set --short "-m" --long "--message" --default "${EZB_LOGO}" --info "Message to print in the banner" &&
        ezb_arg_set --short "-l" --long "--log-prefix" --type "Flag" --info "Print EZ-BASH log prefix" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string && string="$(ezb_arg_get --short "-s" --long "--string" --arguments "${@}")" &&
    local count && count="$(ezb_arg_get --short "-c" --long "--count" --arguments "${@}")" &&
    local message && message="$(ezb_arg_get --short "-m" --long "--message" --arguments "${@}")" &&
    local log_prefix && log_prefix="$(ezb_arg_get --short "-l" --long "--log-prefix" --arguments "${@}")" || return 1
    local line_spliter=$(ezb_string_repeat --string "${string}" --count ${count})
    if [[ "${log_prefix}" = "${EZB_BOOL_TRUE}" ]]; then ezb_log_info "${line_spliter}"; ezb_log_info "${message}"; ezb_log_info "${line_spliter}"
    else echo "${line_spliter}"; echo "${message}"; echo "${line_spliter}"; fi
}
