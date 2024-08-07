function ez.version.extract_digit {
    local digit="$(echo ${1} | cut -d '.' -f ${2})"
    [[ "${3}" = "KeepWildCard" ]] && [[ "${digit}" = "*" ]] && echo "${digit}" && return
    digit="$(sed "s/^\([0-9]*\).*/\1/" <<< "${digit}")" # Trim off the trailing charaters
    [[ -z "${digit}" ]] && echo "0" | bc || echo "${digit}" | bc
}

function ez.version.compare {
    local valid_comparators=("<" ">" "<=" ">=" "=") result
    [[ -z "${1}" ]] && ez.log.error "Invalid left version '${1}'" && return 255
    [[ -z "${3}" ]] && ez.log.error "Invalid right version '${3}'" && return 255
    ez_contains "${2}" "${valid_comparators[@]}" || { ez.log.error "Invalid comparator '${2}'" && return 255; }
    local l_major="$(ez.version.extract_digit ${1} 1)" r_major="$(ez.version.extract_digit ${3} 1)"
    local l_minor="$(ez.version.extract_digit ${1} 2)" r_minor="$(ez.version.extract_digit ${3} 2)"
    local l_patch="$(ez.version.extract_digit ${1} 3)" r_patch="$(ez.version.extract_digit ${3} 3)"
    if [ "${l_major}" -gt "${r_major}" ]; then result=1
    elif [ "${l_major}" -lt "${r_major}" ]; then result=-1
    elif [ "${l_minor}" -gt "${r_minor}" ]; then result=1
    elif [ "${l_minor}" -lt "${r_minor}" ]; then result=-1
    elif [ "${l_patch}" -gt "${r_patch}" ]; then result=1
    elif [ "${l_patch}" -lt "${r_patch}" ]; then result=-1
    else result=0; fi
    if [[ "${2}" = "<" ]]; then [ "${result}" -eq -1 ] && return 0 || return 1
    elif [[ "${2}" = ">" ]]; then [ "${result}" -eq 1 ] && return 0 || return 1
    elif [[ "${2}" = "<=" ]]; then [ "${result}" -le 0 ] && return 0 || return 1
    elif [[ "${2}" = ">=" ]]; then [ "${result}" -ge 0 ] && return 0 || return 1
    else [ "${result}" -eq 0 ] && return 0 || return 1; fi
}

function ez.version.compare_2 {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-o" --long "--operation" --choices ">" ">=" "=" "<=" "<" --required \
                    --info "Must quote operation \">\" and \">=\"" &&
        ez.argument.set --short "-d" --long "--delimiter" --default "." --required --info "Version item delimiter" &&
        ez.argument.set --short "-l" --long "--left-version" --required --info "The version on left side" &&
        ez.argument.set --short "-r" --long "--right-version" --required --info "The version on right side" &&
        ez.argument.set --short "-c" --long "--check-length" --type "Flag" --info "The lengths of the versions must match" &&
        ez.argument.set --short "-p" --long "--print" --type "Flag" --info "Print boolean result" || return 1
    fi
    ez.function.help "${@}" || return 0
    local operation && operation="$(ez.argument.get --short "-o" --long "--operation" --arguments "${@}")" &&
    local delimiter && delimiter="$(ez.argument.get --short "-d" --long "--delimiter" --arguments "${@}")" &&
    local left_version && left_version="$(ez.argument.get --short "-l" --long "--left-version" --arguments "${@}")" &&
    local right_version && right_version="$(ez.argument.get --short "-r" --long "--right-version" --arguments "${@}")" &&
    local check_length && check_length="$(ez.argument.get --short '-c' --long "--check-length" --arguments "${@}")" &&
    local print && print="$(ez.argument.get --short '-p' --long "--print" --arguments "${@}")" || return 1
    local left_version_list=(${left_version//${delimiter}/" "}); local left_length=${#left_version_list[@]}
    local right_version_list=(${right_version//${delimiter}/" "}); local right_length=${#right_version_list[@]}
    if ez.is_true "${check_length}" && [[ "${left_length}" -ne "${right_length}" ]]; then
    	ez.log.error "The length of \"${left_version}\" and \"${right_version}\" does not match"; return 1
    fi
    local state=0; local i=0; while [[ "${i}" -lt "${left_length}" ]] && [[ "${i}" -lt "${right_length}" ]]; do
        ((state = ${left_version_list[${i}]} - ${right_version_list[${i}]})); [[ "${state}" -ne 0 ]] && break; ((++i))
    done
    local result;
    if [[ "${state}" -lt 0 ]]; then
        [[ "${operation}" =~ "<" ]] && result="${EZ_TRUE}" || result="${EZ_FALSE}"
    elif [[ "${state}" -gt 0 ]]; then
        [[ "${operation}" =~ ">" ]] && result="${EZ_TRUE}" || result="${EZ_FALSE}"
    elif [[ "${left_length}" -lt "${right_length}" ]]; then
        [[ "${operation}" =~ "<" ]] && result="${EZ_TRUE}" || result="${EZ_FALSE}"
    elif [[ "${left_length}" -gt "${right_length}" ]]; then
        [[ "${operation}" =~ ">" ]] && result="${EZ_TRUE}" || result="${EZ_FALSE}"
    else
        [[ "${operation}" =~ "=" ]] && result="${EZ_TRUE}" || result="${EZ_FALSE}"
    fi
    ez.is_true "${print}" && echo "${result}"
    ez.is_true "${result}" && return 0 || return 255
}

function ez.version.compare_and_bump_latest {
    local l_major=$(echo "${1}" | cut -d "." -f 1); [[ "${l_major}" = "*" ]] && l_major=0 || l_major=$(echo "${l_major}" | bc)
    local l_minor=$(echo "${1}" | cut -d "." -f 2); [[ "${l_minor}" = "*" ]] && l_minor=0 || l_minor=$(echo "${l_minor}" | bc)
    local l_patch=$(echo "${1}" | cut -d "." -f 3); [[ "${l_patch}" = "*" ]] && l_patch=-1 || l_patch=$(echo "${l_patch}" | bc)
    local r_major=$(echo "${2}" | cut -d "." -f 1); [[ "${r_major}" = "*" ]] && r_major=0 || r_major=$(echo "${r_major}" | bc)
    local r_minor=$(echo "${2}" | cut -d "." -f 2); [[ "${r_minor}" = "*" ]] && r_minor=0 || r_minor=$(echo "${r_minor}" | bc)
    local r_patch=$(echo "${2}" | cut -d "." -f 3); [[ "${r_patch}" = "*" ]] && r_patch=-1 || r_patch=$(echo "${r_patch}" | bc)
    if [[ "${l_major}" -gt "${r_major}" ]]; then
        echo "${l_major}.${l_minor}.$(((l_patch + 1)))"
    elif [[ "${l_major}" -lt "${r_major}" ]]; then
        echo "${r_major}.${r_minor}.$(((r_patch + 1)))"
    elif [[ "${l_minor}" -gt "${r_minor}" ]]; then
        echo "${l_major}.${l_minor}.$(((l_patch + 1)))"
    elif [[ "${l_minor}" -lt "${r_minor}" ]]; then
        echo "${r_major}.${r_minor}.$(((r_patch + 1)))"
    elif [[ "${l_patch}" -gt "${r_patch}" ]]; then
        echo "${l_major}.${l_minor}.$(((l_patch + 1)))"
    else
        echo "${r_major}.${r_minor}.$(((r_patch + 1)))"
    fi
}
