###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "lsof" "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.file.read { cat "${1}"; }
function ez.file.clear { echo -n > "${1}"; }
function ez.file.create {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --default "/var/tmp/dummy" --info "Path to the file" &&
        ez.argument.set --short "-u" --long "--unit" --required --default "B" --choices "B" "K" "M" "G" &&
        ez.argument.set --short "-s" --long "--size" --required || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local unit && unit="$(ez.argument.get --short "-u" --long "--unit" --arguments "${@}")" &&
    local size && size="$(ez.argument.get --short "-s" --long "--size" --arguments "${@}")" || return 1
    [[ "${unit}" == "B" ]] && unit=""
    dd "if=/dev/urandom" "of=${path}" "iflag=fullblock" "bs=1${unit}" "count=${size}"
}

########################################### Lines #################################################
function ez.file.lines.count { wc -l "${1}" | awk '{print $1}'; }
function ez.file.lines.strip { local line; while read -r line; do echo ${line}; done < "${1}"; }
function ez.file.lines.delete {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-k" --long "--keywords" --type "List" --info "List of keywords to be deleted" || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local keywords && ez.function.arguments.get_list "keywords" "$(ez.argument.get --short "-k" --long "--keywords" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        local exclude_string=$(ez.join "\|" "${keywords[@]}")
        cp "${path}" "${path}.bak"
        cat "${path}.bak" | grep -v "${exclude_string}" > "${path}"
        rm "${path}.bak"
    else
        ez.log.error "File \"${path}\" not exist"
    fi
}
function ez.file.lines.read {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-i" --long "--i-th" --info "The i-th line, negative number for reverse order" &&
        ez.argument.set --short "-f" --long "--from" --default "1" --info "From line, negative number for reverse order" &&
        ez.argument.set --short "-t" --long "--to" --default "EOL" --required --info "To line" || return 1
    fi; ez.function.help "${@}" || return 0
    local ith && ith="$(ez.argument.get --short "-i" --long "--i-th" --arguments "${@}")" &&
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local from && from="$(ez.argument.get --short "-f" --long "--from" --arguments "${@}")" &&
    local to && to="$(ez.argument.get --short "-t" --long "--to" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        [[ "${to}" = "EOL" ]] && to=$(cat "${path}" | wc -l | bc)
        if [[ -n "${ith}" ]]; then
            if [[ "${ith}" -gt 0 ]]; then from="${ith}" && to="${ith}"
            elif [[ "${ith}" -lt 0 ]]; then from=$((to + ith + 1)) && to="${from}"
            else ez.log.error "\"--i-th\" cannot be \"0\"" && return 2; fi
        fi
        [[ "${from}" -lt 0 ]] && from=$((to + from + 1))
        [[ "${from}" -le 0 ]] && [[ "${to}" -le 0 ]] && return 2 # For ith < -(file_length)
        if [[ "${from}" -gt "${to}" ]]; then
            ez.log.error "\"--from\" cannot be greater than \"--to\"" && return 2
        else
            sed -n "${from},${to}p" "${path}"
        fi
    else
        ez.log.error "File \"${path}\" not exist"
    fi
}

########################################### Parse #################################################
function ez.file.parse.value {
    #  File Content:
    #  ...key="value"...
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-k" --long "--key" --required --info "The name of the key" || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        grep -oE "${key}=\"(\S+)\"" "${path}" | cut -d "\"" -f 2
    else
        ez.log.error "File \"${path}\" not exist"
    fi
}

function ez.file.parse.ip {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-v" --long "--version" --default "4" --required --choices "4" "6" || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local version && version="$(ez.argument.get --short "-v" --long "--version" --arguments "${@}")" || return 1
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
        ez.log.error "File \"${path}\" not exist"
    fi
}

function ez.file.parse.between_lines {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-s" --long "--start" --required --info "Starting line marker" &&
        ez.argument.set --short "-e" --long "--end" --required --info "Ending line marker" &&
        ez.argument.set --short "-g" --long "--greedy" --type "Flag" --info "Greedy mode" || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local start && start="$(ez.argument.get --short "-s" --long "--start" --arguments "${@}")" &&
    local end && end="$(ez.argument.get --short "-e" --long "--end" --arguments "${@}")" &&
    local greedy && greedy="$(ez.argument.get --short "-g" --long "--greedy" --arguments "${@}")" || return 1
    [[ ! -f "${path}" ]] && ez.log.error "File \"${path}\" not exist" && return 1
    if [[ "${greedy}" = "${EZ_TRUE}" ]]; then
        sed -e "1,/${start}.*/d" -e "/${end}/,\$d" "${path}"
    else
        awk "/${start}/{found=1;next}/${end}/{found=0}found" "${path}"
    fi
}


function ez.file.string_replace {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--path" --required --info "Path to the file" &&
        ez.argument.set --short "-s" --long "--search" --required --info "String to be replaced" &&
        ez.argument.set --short "-r" --long "--replacement" --required --info "Replacement String" || return 1
    fi; ez.function.help "${@}" || return 0
    local path && path="$(ez.argument.get --short "-p" --long "--path" --arguments "${@}")" &&
    local search && search="$(ez.argument.get --short "-s" --long "--search" --arguments "${@}")" &&
    local replacement && replacement="$(ez.argument.get --short "-r" --long "--replacement" --arguments "${@}")" || return 1
    if [[ -f "${path}" ]]; then
        cp "${path}" "${path}.bak"
        sed "s/${search}/${replacement}/g" "${path}.bak" > "${path}" 
        rm "${path}.bak"
    else
        ez.log.error "File \"${path}\" not exist"
    fi
}

function ez.file.descriptor.count {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-p" --long "--process-id" --info "Process ID" &&
        ez.argument.set --short "-n" --long "--process-name" --info "Process Name, only works for linux" || return 1
    fi; ez.function.help "${@}" || return 0
    local pid && pid="$(ez.argument.get --short "-p" --long "--process-id" --arguments "${@}")" &&
    local name && name="$(ez.argument.get --short "-n" --long "--process-name" --arguments "${@}")" || return 1
    local fd_count=0
    if [[ -n "${pid}" ]] && [[ -n "${name}" ]]; then ez.log.error "Cannot use --pid and --name together" && return 1
    elif [[ -z "${pid}" ]] && [[ -z "${name}" ]]; then ez.log.error "Must provide --pid or --name" && return 1
    elif [[ -z "${pid}" ]]; then
        if [[ "$(uname -s)" = "Linux" ]]; then
            for pid in $(pgrep -f "${name}"); do fd_count=$(echo "${fd_count} + $(ls -l /proc/${pid}/fd | wc -l | bc)" | bc); done
        else
            ez.log.error "\"--name\" only works on linux" && return 1
        fi
    else
        if [[ "${os}" = "linux" ]]; then fd_count=$(ls -1 /proc/${pid}/fd | wc -l | bc)
        elif [[ "${os}" = "macos" ]]; then fd_count=$(lsof -p ${pid} | wc -l | bc); fi
    fi    
    echo "${fd_count}"
}

function ez.backup {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-s" --long "--source" --required --info "The path of a file or directory to be backed up" &&
        ez.argument.set --short "-b" --long "--backup" --required --default "${HOME}/backups" --info "Backup directory path" ||
        return 1
    fi; ez.function.help "${@}" || return 0
    local source && source="$(ez.argument.get --short "-s" --long "--source" --arguments "${@}")" &&
    local backup && backup="$(ez.argument.get --short "-b" --long "--backup" --arguments "${@}")" || return 1
    [[ -n "${backup}" ]] && mkdir -p "${backup}"
    [[ ! -d "${backup}" ]] && ez.log.error "Backup directory \"${backup}\" not found" && return 1
    local source_basename="$(basename "${source}")"
    [[ -z "${source_basename}" ]] && ez.log.error "Invalid source basename \"${source_basename}\"" && return 1
    local destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    [[ -e "${destination_path}" ]] && sleep 1 && destination_path="${backup}/${source_basename}.$(date +%Y_%m_%d_%H_%M_%S)"
    cp -r "${source}" "${destination_path}"
    ls -lah "${backup}" | grep "${source_basename}"
    ez.log --logger "Complete" --message  "Backup at ${destination_path}"; echo
}
