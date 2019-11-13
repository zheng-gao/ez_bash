function ezb_os_name() {
    local name="$(uname -s)"
    if [[ "${name}" = "Darwin" ]]; then echo "macos"
    elif [[ "${name}" = "Linux" ]]; then echo "linux"
    else echo "Unknown"; fi
}

function ezb_cmd_md5() {
    local os=$(ezb_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! ezb_check_cmd "md5"; then ez_log_error "Not found \"md5\", please run \"brew install md5\""
        else echo "md5 -q"; fi
    elif [[ "${os}" = "linux" ]]; then
        if ! ezb_check_cmd "md5sum"; then ez_log_error "Not found \"md5sum\", please run \"yum install md5sum\""
        else echo "md5sum"; fi
    fi
}

function ezb_file_descriptor_count() {
    if ! ez_function_exist; then
        ez_set_argument --short "-p" --long "--process-id" --info "Process ID" &&
        ez_set_argument --short "-n" --long "--process-name" --info "Process Name, only works for linux" ||
        return 1
    fi
    ezb_function_usage "${@}" && return
    local pid="$(ez_get_argument --short "-p" --long "--process-id" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local name="$(ez_get_argument --short "-n" --long "--process-name" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local fd_count=0
    local os=$(ezb_os_name)
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
        elif [[ "${os}" = "macos" ]]; then fd_count=$(lsof -p ${pid} | wc -l | bc)
        fi
    fi    
    echo "${fd_count}"
}

