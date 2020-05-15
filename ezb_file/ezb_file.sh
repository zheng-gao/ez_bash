###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "wc" "cat" "bc"  "sed" "lsof" "grep" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_file_string_replace() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ezb_arg_set --short "-s" --long "--search" --required --info "String to be replaced" &&
        ezb_arg_set --short "-r" --long "--replacement" --required --info "Replacement String" || return 1
    fi
    ezb_function_usage "${@}" && return
    local path && path="$(ezb_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local search && search="$(ezb_arg_get --short "-s" --long "--search" --arguments "${@}")" &&
    local replacement && replacement="$(ezb_arg_get --short "-r" --long "--replacement" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        cp "${path}" "${path}.bak"
        sed "s/${search}/${replacement}/g" "${path}.bak" > "${path}" 
        rm "${path}.bak"
    else
        ezb_log_error "File \"${path}\" not exist"
    fi
}

function ezb_file_delete_lines() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ezb_arg_set --short "-k" --long "--keywords" --type "List" --info "List of keywords to be deleted" || return 1
    fi
    ezb_function_usage "${@}" && return
    local path && path="$(ezb_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local keywords && keywords="$(ezb_arg_get --short "-k" --long "--keywords" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        local exclude_list=($(ezb_function_get_list "${keywords}"))
        local exclude_string=$(ezb_join "\|" "${exclude_list[@]}")
        cp "${path}" "${path}.bak"
        cat "${path}.bak" | grep -v "${exclude_string}" > "${path}"
        rm "${path}.bak"
    else
        ezb_log_error "File \"${path}\" not exist"
    fi
}

function ezb_file_get_lines() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ezb_arg_set --short "-i" --long "--i-th" --info "The i-th line, negative number for reverse order" &&
        ezb_arg_set --short "-f" --long "--from" --default "1" --info "From line, negative number for reverse order" &&
        ezb_arg_set --short "-t" --long "--to" --default "EOL" --required --info "To line" || return 1
    fi
    ezb_function_usage "${@}" && return
    local ith && ith="$(ezb_arg_get --short "-i" --long "--i-th" --arguments "${@}")" &&
    local path && path="$(ezb_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local from && from="$(ezb_arg_get --short "-f" --long "--from" --arguments "${@}")" &&
    local to && to="$(ezb_arg_get --short "-t" --long "--to" --arguments "${@}")" || return 1
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

function ezb_file_descriptor_count() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--process-id" --info "Process ID" &&
        ezb_arg_set --short "-n" --long "--process-name" --info "Process Name, only works for linux" || return 1
    fi
    ezb_function_usage "${@}" && return
    local pid && pid="$(ezb_arg_get --short "-p" --long "--process-id" --arguments "${@}")" &&
    local name && name="$(ezb_arg_get --short "-n" --long "--process-name" --arguments "${@}")" || return 1
    local fd_count=0; local os=$(ezb_os_name)
    if [[ -n "${pid}" ]] && [[ -n "${name}" ]]; then ezb_log_error "Cannot use --pid and --name together" && return 1
    elif [[ -z "${pid}" ]] && [[ -z "${name}" ]]; then ezb_log_error "Must provide --pid or --name" && return 1
    elif [[ -z "${pid}" ]]; then
        if [[ "${os}" = "linux" ]]; then
            for pid in $(pgrep -f "${name}"); do fd_count=$(echo "${fd_count} + $(ls -l /proc/${pid}/fd | wc -l | bc)" | bc); done
        elif [[ "${os}" = "macos" ]]; then
            ezb_log_error "\"--name\" only works on linux" && return 1
        fi
    else
        if [[ "${os}" = "linux" ]]; then fd_count=$(ls -1 /proc/${pid}/fd | wc -l | bc)
        elif [[ "${os}" = "macos" ]]; then fd_count=$(lsof -p ${pid} | wc -l | bc); fi
    fi    
    echo "${fd_count}"
}

function ezb_backup() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-s" --long "--source" --required --info "The path of a file or directory to be backed up" &&
        ezb_arg_set --short "-b" --long "--backup" --required --default "${HOME}/backups" --info "Backup directory path" ||
        return 1
    fi
    ezb_function_usage "${@}" && return
    local source && source="$(ezb_arg_get --short "-s" --long "--source" --arguments "${@}")" &&
    local backup && backup="$(ezb_arg_get --short "-b" --long "--backup" --arguments "${@}")" || return 1
    [[ -n "${backup}" ]] && mkdir -p "${backup}"
    [[ ! -d "${backup}" ]] && ezb_log_error "Backup directory \"${backup}\" not found" && return 1
    local source_basename="$(basename "${source}")"
    [[ -z "${source_basename}" ]] && ezb_log_error "Invalid source basename \"${source_basename}\"" && return 1
    local destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    [[ -e "${destination_path}" ]] && sleep 1 && destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    cp -r "${source}" "${destination_path}"
    ls -lah "${backup}" | grep "${source_basename}"
    ezb_log --logger "Complete" --message  "Backup at ${destination_path}"; echo
}
