function ezb_string_length() {
    local input_string="${1}"
    echo "${#input_string}"
}

function ezb_string_repeat() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-s" --long "--string" --required --default "=" --info "String to be repeated" &&
        ezb_set_arg --short "-c" --long "--count" --required --default "80" --info "The count of the substrings" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string; string="$(ezb_get_arg --short "-s" --long "--string" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local count; count="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [[ "${count}" -lt 0 ]] && ezb_log_error "Invalid Count \"${count}\"" && return 1
    local line=""; local index=0; for ((; "${index}" < "${count}"; ++index)); do line+="${string}"; done; echo "${line}"
}

function ezb_string_trim() {
    if ! ezb_function_exist; then
        local valid_keys=("Left" "Right" "Both" "Any")
        ezb_set_arg --short "-s" --long "--string" --required --info "The string to be trimmed" &&
        ezb_set_arg --short "-p" --long "--pattern" --required --default "${EZB_CHAR_SPACE}" --info "Substring Pattern" &&
        ezb_set_arg --short "-c" --long "--count" --info "Occurrence of the pattern" &&
        ezb_set_arg --short "-k" --long "--key" --required --default "Any" --choices "${valid_keys[@]}" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string; string="$(ezb_get_arg --short "-s" --long "--string" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pattern; pattern="$(ezb_get_arg --short "-p" --long "--pattern" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local count; count="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local key; key="$(ezb_get_arg --short "-k" --long "--key" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
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

function ezb_string_check() {
    if ! ezb_function_exist; then
        local valid_keys=("Contains" "Starts" "Ends")
        ezb_set_arg --short "-s" --long "--string" --required --info "The string to be checked" &&
        ezb_set_arg --short "-p" --long "--pattern" --required --info "Substring Pattern" &&
        ezb_set_arg --short "-k" --long "--key" --required --default "Contains" --choices "${valid_keys[@]}" &&
        ezb_set_arg --short "-v" --long "--verbose" --type "Flag" --info "Print result" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string; string="$(ezb_get_arg --short "-s" --long "--string" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pattern; pattern="$(ezb_get_arg --short "-p" --long "--pattern" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local key; key="$(ezb_get_arg --short "-k" --long "--key" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local verbose; verbose="$(ezb_get_arg --short "-v" --long "--verbose" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
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
    if ! ezb_function_exist; then
        local valid_keys=("Contains" "Starts" "Ends")
        ezb_set_arg --short "-s" --long "--string" --required --default "=" --info "The string in the line spliter" &&
        ezb_set_arg --short "-c" --long "--count" --required --default "80" --info "The number of the strings in the line spliter" &&
        ezb_set_arg --short "-m" --long "--message" --default "${EZB_LOGO}" --info "Message to print in the banner" &&
        ezb_set_arg --short "-l" --long "--log-prefix" --type "Flag" --info "Print EZ-BASH log prefix" || return 1
    fi
    ezb_function_usage "${@}" && return
    local string; string="$(ezb_get_arg --short "-s" --long "--string" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local count; count="$(ezb_get_arg --short "-c" --long "--count" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local message; message="$(ezb_get_arg --short "-m" --long "--message" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local log_prefix; log_prefix="$(ezb_get_arg --short "-l" --long "--log-prefix" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local line_spliter=$(ezb_string_repeat --string "${string}" --count ${count})
    if [[ "${log_prefix}" = "${EZB_BOOL_TRUE}" ]]; then ezb_log_info "${line_spliter}"; ezb_log_info "${message}"; ezb_log_info "${line_spliter}"
    else echo "${line_spliter}"; echo "${message}"; echo "${line_spliter}"; fi
}
