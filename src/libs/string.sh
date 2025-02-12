###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.string.contains { local string="${1}" substring="${2}"; [[ "${string}" == *"${substring}"* ]]; }
function ez.string.replace { local string="${1}" pattern="${2}" replacement="${3}"; echo "${string//${pattern}/${replacement}}"; }
function ez.string.count_substring { local input_string="${1}" substring="${2}"; echo "${input_string}" | grep -o "${substring}" | wc -l | bc; }

function ez.string.repeat {
    if ez.function.unregistered; then
        ez.argument.set --short "-s" --long "--string" --required --default "=" --info "String to be repeated" &&
        ez.argument.set --short "-c" --long "--count" --required --default "80" --info "The count of the substrings" || return 1
    fi; ez.function.help "${@}" || return 0
    local string && string="$(ez.argument.get --short "-s" --long "--string" --arguments "${@}")" &&
    local count && count="$(ez.argument.get --short "-c" --long "--count" --arguments "${@}")" || return 1
    [[ "${count}" -lt 0 ]] && ez.log.error "Invalid Count \"${count}\"" && return 1
    local line index=0; for ((; "${index}" < "${count}"; ++index)); do line+="${string}"; done; echo "${line}"
}

function ez.string.trim {
    if ez.function.unregistered; then
        local valid_keys=("Left" "Right" "Both" "Any")
        ez.argument.set --short "-s" --long "--string" --required --info "The string to be trimmed" &&
        ez.argument.set --short "-p" --long "--pattern" --required --default "${EZ_CHAR_SPACE}" --info "Substring Pattern" &&
        ez.argument.set --short "-c" --long "--count" --info "Occurrence of the pattern" &&
        ez.argument.set --short "-k" --long "--key" --required --default "Any" --choices "${valid_keys[@]}" || return 1
    fi; ez.function.help "${@}" || return 0
    local string && string="$(ez.argument.get --short "-s" --long "--string" --arguments "${@}")" &&
    local pattern && pattern="$(ez.argument.get --short "-p" --long "--pattern" --arguments "${@}")" &&
    local count && count="$(ez.argument.get --short "-c" --long "--count" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" || return 1
    if [[ "${pattern}" =  "${EZ_CHAR_SPACE}" ]]; then pattern=" "; fi
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

function ez.string.cut {
    if ez.function.unregistered; then
        local valid_keys=("Left" "Right" "Both")
        ez.argument.set --short "-s" --long "--string" --required --info "The string to be cut" &&
        ez.argument.set --short "-l" --long "--length" --info "Length to be cut" &&
        ez.argument.set --short "-k" --long "--key" --required --default "Left" --choices "${valid_keys[@]}" || return 1
    fi; ez.function.help "${@}" || return 0
    local string && string="$(ez.argument.get --short "-s" --long "--string" --arguments "${@}")" &&
    local length && length="$(ez.argument.get --short "-l" --long "--length" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" || return 1
    case "${key}" in
        "Left") echo "${string:${length}}" ;;
        "Right") echo "${string::-${length}}" ;;
        *) echo "${string:${length}:-${length}}" ;;
    esac
}

function ez.string.check {
    if ez.function.unregistered; then
        local valid_keys=("Contains" "Starts" "Ends")
        ez.argument.set --short "-s" --long "--string" --required --info "The string to be checked" &&
        ez.argument.set --short "-p" --long "--pattern" --required --info "Substring Pattern" &&
        ez.argument.set --short "-k" --long "--key" --required --default "Contains" --choices "${valid_keys[@]}" &&
        ez.argument.set --short "-v" --long "--verbose" --type "Flag" --info "Print result" || return 1
    fi; ez.function.help "${@}" || return 0
    local string && string="$(ez.argument.get --short "-s" --long "--string" --arguments "${@}")" &&
    local pattern && pattern="$(ez.argument.get --short "-p" --long "--pattern" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" &&
    local verbose && verbose="$(ez.argument.get --short "-v" --long "--verbose" --arguments "${@}")" || return 1
    if [[ "${key}" = "Contains" ]]; then
        if [[ "${string}" = *"${pattern}"* ]]; then ez.is_true "${verbose}" && echo "${EZ_TRUE}"; return 0
        else ez.is_true "${verbose}" && echo "${EZ_FALSE}"; return 2; fi
    elif [[ "${key}" == "Starts" ]]; then
        if [[ "${string}" =~ ^"${pattern}".* ]]; then ez.is_true "${verbose}" && echo "${EZ_TRUE}"; return 0
        else ez.is_true "${verbose}" && echo "${EZ_FALSE}"; return 2; fi
    elif [[ "${key}" == "Ends" ]]; then
        if [[ "${string}" =~ .*"${pattern}"$ ]]; then ez.is_true"${verbose}" && echo "${EZ_TRUE}"; return 0
        else ez.is_true "${verbose}" && echo "${EZ_FALSE}"; return 2; fi
    fi
}

function ez.string.banner {
    if ez.function.unregistered; then
        local valid_keys=("Contains" "Starts" "Ends")
        ez.argument.set --short "-s" --long "--string" --required --default "=" --info "The string item in the line spliter" &&
        ez.argument.set --short "-c" --long "--count" --required --default "80" --info "The number of the string items in the line spliter" &&
        ez.argument.set --short "-m" --long "--message" --default "${EZ_SELF_LOGO}" --info "Message to print in the banner" &&
        ez.argument.set --short "-e" --long "--effect" --info "The string effect" &&
        ez.argument.set --short "-f" --long "--foreground-color" --info "The string foreground color" &&
        ez.argument.set --short "-b" --long "--background-color" --info "The string background color" &&
        ez.argument.set --short "-l" --long "--log-prefix" --type "Flag" --info "Print EZ-BASH log prefix" || return 1
    fi; ez.function.help "${@}" || return 0
    local string && string="$(ez.argument.get --short "-s" --long "--string" --arguments "${@}")" &&
    local count && count="$(ez.argument.get --short "-c" --long "--count" --arguments "${@}")" &&
    local message && message="$(ez.argument.get --short "-m" --long "--message" --arguments "${@}")" &&
    local effect && effect="$(ez.argument.get --short "-e" --long "--effect" --arguments "${@}")" &&
    local f_color && f_color="$(ez.argument.get --short "-f" --long "--foreground-color" --arguments "${@}")" &&
    local b_color && b_color="$(ez.argument.get --short "-b" --long "--background-color" --arguments "${@}")" &&
    local log_prefix && log_prefix="$(ez.argument.get --short "-l" --long "--log-prefix" --arguments "${@}")" || return 1
    local line_spliter=$(ez.string.repeat --string "${string}" --count ${count})
    if ez.is_true "${log_prefix}"; then
        ez.log.info "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${line_spliter}")"
        ez.log.info "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${message}")"
        ez.log.info "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${line_spliter}")"
    else
        echo -e "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${line_spliter}")"
        echo -e "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${message}")"
        echo -e "$(ez.text.decorate -e "${effect}" -f "${f_color}" -b "${b_color}" -t "${line_spliter}")"
    fi
}
