###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "lsof" "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_file_read_lines { local file="${1}" line; while read -r line; do echo ${line}; done < "${file}"; }
function ez_file_clear { echo -n > "${1}"; }
function ez_file_lines { wc -l "${1}" | awk '{print $1}'; }

function ez_file_create_dummy {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --default "/var/tmp/dummy" --info "Path to the file" &&
        ez_arg_set --short "-s" --long "--size" --required --info "Size in MB" || return 1
    fi
    ez_function_usage "${@}" && return
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local size && size="$(ez_arg_get --short "-s" --long "--size" --arguments "${@}")" || return 1
    local os=$(ez_os_name)
    if [[ "${os}" = "linux" ]]; then
        dd "if=/dev/random" "of=${path}" "bs=4k" "iflag=fullblock,count_bytes" "count=${size}M"
        # dd "if=/dev/zero" "of=${path}" "bs=${size}M" "count=1"
    elif [[ "${os}" = "macos" ]]; then
        mkfile "${size}m" "${path}"
    else
        ez_log_error "The OS \"${os}\" is not supported"
    fi
}

function ez_file_string_replace {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_arg_set --short "-s" --long "--search" --required --info "String to be replaced" &&
        ez_arg_set --short "-r" --long "--replacement" --required --info "Replacement String" || return 1
    fi
    ez_function_usage "${@}" && return
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local search && search="$(ez_arg_get --short "-s" --long "--search" --arguments "${@}")" &&
    local replacement && replacement="$(ez_arg_get --short "-r" --long "--replacement" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        cp "${path}" "${path}.bak"
        sed "s/${search}/${replacement}/g" "${path}.bak" > "${path}" 
        rm "${path}.bak"
    else
        ez_log_error "File \"${path}\" not exist"
    fi
}

function ez_file_delete_lines {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_arg_set --short "-k" --long "--keywords" --type "List" --info "List of keywords to be deleted" || return 1
    fi
    ez_function_usage "${@}" && return
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local keywords && ez_function_get_list "keywords" "$(ez_arg_get --short "-k" --long "--keywords" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        local exclude_string=$(ez_join "\|" "${keywords[@]}")
        cp "${path}" "${path}.bak"
        cat "${path}.bak" | grep -v "${exclude_string}" > "${path}"
        rm "${path}.bak"
    else
        ez_log_error "File \"${path}\" not exist"
    fi
}

function ez_file_get_lines {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_arg_set --short "-i" --long "--i-th" --info "The i-th line, negative number for reverse order" &&
        ez_arg_set --short "-f" --long "--from" --default "1" --info "From line, negative number for reverse order" &&
        ez_arg_set --short "-t" --long "--to" --default "EOL" --required --info "To line" || return 1
    fi
    ez_function_usage "${@}" && return
    local ith && ith="$(ez_arg_get --short "-i" --long "--i-th" --arguments "${@}")" &&
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local from && from="$(ez_arg_get --short "-f" --long "--from" --arguments "${@}")" &&
    local to && to="$(ez_arg_get --short "-t" --long "--to" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        [[ "${to}" = "EOL" ]] && to=$(cat "${path}" | wc -l | bc)
        if [[ -n "${ith}" ]]; then
            if [[ "${ith}" -gt 0 ]]; then from="${ith}" && to="${ith}"
            elif [[ "${ith}" -lt 0 ]]; then from=$((to + ith + 1)) && to="${from}"
            else ez_log_error "\"--i-th\" cannot be \"0\"" && return 2; fi
        fi
        [[ "${from}" -lt 0 ]] && from=$((to + from + 1))
        [[ "${from}" -le 0 ]] && [[ "${to}" -le 0 ]] && return 2 # For ith < -(file_length)
        if [[ "${from}" -gt "${to}" ]]; then
            ez_log_error "\"--from\" cannot be greater than \"--to\"" && return 2
        else
            sed -n "${from},${to}p" "${path}"
        fi
    else
        ez_log_error "File \"${path}\" not exist"
    fi
}

function ez_file_descriptor_count {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--process-id" --info "Process ID" &&
        ez_arg_set --short "-n" --long "--process-name" --info "Process Name, only works for linux" || return 1
    fi
    ez_function_usage "${@}" && return
    local pid && pid="$(ez_arg_get --short "-p" --long "--process-id" --arguments "${@}")" &&
    local name && name="$(ez_arg_get --short "-n" --long "--process-name" --arguments "${@}")" || return 1
    local fd_count=0; local os=$(ez_os_name)
    if [[ -n "${pid}" ]] && [[ -n "${name}" ]]; then ez_log_error "Cannot use --pid and --name together" && return 1
    elif [[ -z "${pid}" ]] && [[ -z "${name}" ]]; then ez_log_error "Must provide --pid or --name" && return 1
    elif [[ -z "${pid}" ]]; then
        if [[ "${os}" = "linux" ]]; then
            for pid in $(pgrep -f "${name}"); do fd_count=$(echo "${fd_count} + $(ls -l /proc/${pid}/fd | wc -l | bc)" | bc); done
        elif [[ "${os}" = "macos" ]]; then
            ez_log_error "\"--name\" only works on linux" && return 1
        fi
    else
        if [[ "${os}" = "linux" ]]; then fd_count=$(ls -1 /proc/${pid}/fd | wc -l | bc)
        elif [[ "${os}" = "macos" ]]; then fd_count=$(lsof -p ${pid} | wc -l | bc); fi
    fi    
    echo "${fd_count}"
}

function ez_file_parse_value {
    #  File Content:
    #  ...key="value"...
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_arg_set --short "-k" --long "--key" --required --info "The name of the key" || return 1
    fi
    ez_function_usage "${@}" && return
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local key && key="$(ez_arg_get --short "-k" --long "--key" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        grep -oE "${key}=\"(\S+)\"" "${path}" | cut -d "\"" -f 2
    else
        ez_log_error "File \"${path}\" not exist"
    fi
}

function ez_file_parse_ip {
    if ez_function_unregistered; then
        ez_arg_set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez_arg_set --short "-v" --long "--version" --default "4" --required --choices "4" "6" || return 1
    fi
    ez_function_usage "${@}" && return
    local path && path="$(ez_arg_get --short "-p" --long "--path" --arguments "${@}")" &&
    local version && version="$(ez_arg_get --short "-v" --long "--version" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        {
            echo "Count IPv${version}"
            if [[ "${version}" = "4" ]]; then    
                grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "${path}" | sort | uniq -c | sort -nr
            else
                grep -oE "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))" "${path}" | sort | uniq -c | sort -nr
            fi
        } | column -s " " -t
    else
        ez_log_error "File \"${path}\" not exist"
    fi
}

function ez_backup {
    if ez_function_unregistered; then
        ez_arg_set --short "-s" --long "--source" --required --info "The path of a file or directory to be backed up" &&
        ez_arg_set --short "-b" --long "--backup" --required --default "${HOME}/backups" --info "Backup directory path" ||
        return 1
    fi
    ez_function_usage "${@}" && return
    local source && source="$(ez_arg_get --short "-s" --long "--source" --arguments "${@}")" &&
    local backup && backup="$(ez_arg_get --short "-b" --long "--backup" --arguments "${@}")" || return 1
    [[ -n "${backup}" ]] && mkdir -p "${backup}"
    [[ ! -d "${backup}" ]] && ez_log_error "Backup directory \"${backup}\" not found" && return 1
    local source_basename="$(basename "${source}")"
    [[ -z "${source_basename}" ]] && ez_log_error "Invalid source basename \"${source_basename}\"" && return 1
    local destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    [[ -e "${destination_path}" ]] && sleep 1 && destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    cp -r "${source}" "${destination_path}"
    ls -lah "${backup}" | grep "${source_basename}"
    ez_log --logger "Complete" --message  "Backup at ${destination_path}"; echo
}
