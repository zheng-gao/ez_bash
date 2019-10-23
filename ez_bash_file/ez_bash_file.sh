###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_file_get_lines() {
    if ! ez_function_exist; then
	    ez_set_argument --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_set_argument --short "-f" --long "--from" --default "1" --info "From line" &&
        ez_set_argument --short "-t" --long "--to" --default "EOL" --required --info "To line" ||
        return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local path; path="$(ez_get_argument --short "-p" --long "--path" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local from; from="$(ez_get_argument --short "-f" --long "--from" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local to; to="$(ez_get_argument --short "-t" --long "--to" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ -f "${path}" ]]; then
        [[ "${to}" = "EOL" ]] && to=$(cat "${path}" | wc -l | bc)
        [[ "${from}" -lt 0 ]] && from=$((to + from + 1))
        [[ "${from}" -le 0 ]] && from=1
        if [[ "${from}" -gt "${to}" ]]; then
            ez_log_error "\"--from\" cannot be greater than \"--to\"" && return 2
        else
            sed -n "${from},${to}p" "${path}"
        fi
    else
    	ez_log_error "File \"${path}\" not exist"
    fi
}
