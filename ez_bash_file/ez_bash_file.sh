###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_get_lines() {
	ez_set_argument --short "-p" --long "--path" --required --info "Path to the file" &&
    ez_set_argument --short "-f" --long "--from" --default 1 --info "From line" &&
    ez_set_argument --short "-t" --long "--to" --required --info "To line" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local path; path="$(ez_get_argument --short "-p" --long "--path" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local from; from="$(ez_get_argument --short "-f" --long "--from" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local to; to="$(ez_get_argument --short "-t" --long "--to" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    if [[ "${from}" -gt "${to}" ]]; then ez_log_error "\"--from\" cannot be greater than \"--to\"" && return 2; fi
    if [[ -f "${path}" ]]; then
        sed -n "${from},${to}p" "${path}"
    else
    	ez_log_error "File \"${path}\" not exist"
    fi
}
