function ezb_file_get_lines() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-p" --long "--path" --required --info "Path to the file" &&
        ezb_set_arg --short "-i" --long "--i-th" --info "The i-th line, negative number for reverse order" &&
        ezb_set_arg --short "-f" --long "--from" --default "1" --info "From line, negative number for reverse order" &&
        ezb_set_arg --short "-t" --long "--to" --default "EOL" --required --info "To line" ||
        return 1
    fi
    ezb_function_usage "${@}" && return
    local ith; ith="$(ezb_get_arg --short "-i" --long "--i-th" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local path; path="$(ezb_get_arg --short "-p" --long "--path" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local from; from="$(ezb_get_arg --short "-f" --long "--from" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local to; to="$(ezb_get_arg --short "-t" --long "--to" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ -f "${path}" ]]; then
        [[ "${to}" = "EOL" ]] && to=$(cat "${path}" | wc -l | bc)
        if [[ -n "${ith}" ]]; then
            if [[ "${ith}" -gt 0 ]]; then from="${ith}" && to="${ith}"
            elif [[ "${ith}" -lt 0 ]]; then from=$((to + ith + 1)) && to="${from}"
            else ezb_log_error "\"--i-th\" cannot be \"0\"" && return 2; fi
        fi
        [[ "${from}" -lt 0 ]] && from=$((to + from + 1))
        [[ "${from}" -le 0 ]] && [[ "${to}" -le 0 ]] && return 2 # For ith < -(file_length)
        if [[ "${from}" -gt "${to}" ]]; then
            ezb_log_error "\"--from\" cannot be greater than \"--to\"" && return 2
        else
            sed -n "${from},${to}p" "${path}"
        fi
    else
        ezb_log_error "File \"${path}\" not exist"
    fi
}
