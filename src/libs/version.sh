function ez_version_compare {
    if ez_function_unregistered; then
        ez_arg_set --short "-o" --long "--operation" --choices ">" ">=" "=" "<=" "<" --required \
                    --info "Must quote operation \">\" and \">=\"" &&
        ez_arg_set --short "-d" --long "--delimiter" --default "." --required --info "Version item delimiter" &&
        ez_arg_set --short "-l" --long "--left-version" --required --info "The version on left side" &&
        ez_arg_set --short "-r" --long "--right-version" --required --info "The version on right side" &&
        ez_arg_set --short "-c" --long "--check-length" --type "Flag" --info "The lengths of the versions must match" &&
        ez_arg_set --short "-p" --long "--print" --type "Flag" --info "Print boolean result" || return 1
    fi
    ez_function_usage "${@}" && return
    local operation && operation="$(ez_arg_get --short "-o" --long "--operation" --arguments "${@}")" &&
    local delimiter && delimiter="$(ez_arg_get --short "-d" --long "--delimiter" --arguments "${@}")" &&
    local left_version && left_version="$(ez_arg_get --short "-l" --long "--left-version" --arguments "${@}")" &&
    local right_version && right_version="$(ez_arg_get --short "-r" --long "--right-version" --arguments "${@}")" &&
    local check_length && check_length="$(ez_arg_get --short '-c' --long "--check-length" --arguments "${@}")" &&
    local print && print="$(ez_arg_get --short '-p' --long "--print" --arguments "${@}")" || return 1
    local left_version_list=(${left_version//${delimiter}/" "}); local left_length=${#left_version_list[@]}
    local right_version_list=(${right_version//${delimiter}/" "}); local right_length=${#right_version_list[@]}
    if [[ "${check_length}" = "${EZ_BOOL_TRUE}" ]] && [[ "${left_length}" -ne "${right_length}" ]]; then
    	ez_log_error "The length of \"${left_version}\" and \"${right_version}\" does not match"; return 1
    fi
    local state=0; local i=0; while [[ "${i}" -lt "${left_length}" ]] && [[ "${i}" -lt "${right_length}" ]]; do
        ((state = ${left_version_list[${i}]} - ${right_version_list[${i}]})); [[ "${state}" -ne 0 ]] && break; ((++i))
    done
    local result;
    if [[ "${state}" -lt 0 ]]; then
        [[ "${operation}" =~ "<" ]] && result="${EZ_BOOL_TRUE}" || result="${EZ_BOOL_FALSE}"
    elif [[ "${state}" -gt 0 ]]; then
        [[ "${operation}" =~ ">" ]] && result="${EZ_BOOL_TRUE}" || result="${EZ_BOOL_FALSE}"
    elif [[ "${left_length}" -lt "${right_length}" ]]; then
        [[ "${operation}" =~ "<" ]] && result="${EZ_BOOL_TRUE}" || result="${EZ_BOOL_FALSE}"
    elif [[ "${left_length}" -gt "${right_length}" ]]; then
        [[ "${operation}" =~ ">" ]] && result="${EZ_BOOL_TRUE}" || result="${EZ_BOOL_FALSE}"
    else
        [[ "${operation}" =~ "=" ]] && result="${EZ_BOOL_TRUE}" || result="${EZ_BOOL_FALSE}"
    fi
    [[ "${print}" =  "${EZ_BOOL_TRUE}" ]] && echo "${result}"
    [[ "${result}" = "${EZ_BOOL_TRUE}" ]] && return 0 || return 255
}