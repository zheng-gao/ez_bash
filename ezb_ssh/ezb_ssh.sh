###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
if ! ezb_dependency_check "expect"; then return 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

# SSH and switch to root using the password, Save output in $save_to
# timeout=-1 means no timeout, if you give wrong "prompt", it will hang forever
function ezb_ssh_sudo_cmd() {
    if ! ezb_function_exist; then
        ezb_arg_set --short "-h" --long "--host" --required --info "The host to run the command on" &&
        ezb_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ezb_arg_set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ezb_arg_set --short "-p" --long "--password" --info "The root password" &&
        ezb_arg_set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ezb_arg_set --short "-s" --long "--status" --type "Flag" --info "Print status" &&
        ezb_arg_set --short "-C" --long "--console" --type "Flag" --info "Print output to console" &&
        ezb_arg_set --short "-o" --long "--output" --info "File path for output" &&
        ezb_arg_set --short "-P" --long "--prompt" --required --default "${EZB_CHAR_SHARP}-${EZB_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZB_CHAR_SPACE}\" for \"app\" user" || return 0
    fi
    ezb_function_usage "${@}" && return
    local host && host="$(ezb_arg_get --short "-h" --long "--host" --arguments "${@}")" &&
    local command && command="$(ezb_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ezb_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ezb_arg_get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ezb_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local status && status="$(ezb_arg_get --short "-s" --long "--status" --arguments "${@}")" &&
    local console && console="$(ezb_arg_get --short "-C" --long "--console" --arguments "${@}")" &&
    local output && output="$(ezb_arg_get --short "-o" --long "--output" --arguments "${@}")" &&
    local prompt && prompt="$(ezb_arg_get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    local data_file="${EZB_DIR_DATA}/${FUNCNAME[0]}.${host}.${user}.$(date '+%F_%H-%M-%S')"; [[ -f "${data_file}" ]] && rm -f "${data_file}"
    [[ "${user}" = "root" ]] && user=""; [[ "${user}" = "${USER}" ]] && user="-"
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    prompt=$(sed "s/${EZB_CHAR_SPACE}/ /g" <<< "${prompt}")
    prompt=$(sed "s/${EZB_CHAR_SHARP}-/#/g" <<< "${prompt}")
    local start_banner="EZ-BASH-Command-Start"; local status_banner="EZ-BASH-Command-Status"
    {
        expect << EOF
        set timeout "${timeout}"
        spawn ssh -o StrictHostKeyChecking=no ${host}
        send "sudo su - ${user}\r"; expect "assword"
        send -- "${password}\r"; expect "${prompt}"
        send "echo ${start_banner}\r"; expect "${prompt}"
        send "${command}\r"; expect "${prompt}"
        send "echo ${status_banner}$\{\?\}${status_banner}\r"; expect "${prompt}"
        send "echo\r"; expect "${prompt}" # make sure the prompt is present
EOF
        echo
    } &> "${data_file}"
    local start_line=$(grep -n "${start_banner}" ${data_file} | tail -1 | cut -d ":" -f 1)
    local end_line=$(grep -n "echo ${status_banner}" ${data_file} | tail -1 | cut -d ":" -f 1)
    start_line=$((start_line+=2)); end_line=$((end_line-=1))
    [[ "${console}" = "${EZB_BOOL_TRUE}" ]] && sed -n "${start_line},${end_line}p" "${data_file}"
    [[ -n "${output}" ]] && sed -n "${start_line},${end_line}p" "${data_file}" > "${output}"
    local status_string=$(grep "${status_banner}" "${data_file}" | grep -v "echo") # get the $?
    if [[ "${status_string}" != "${status_banner}0${status_banner}"* ]]; then
        [[ "${status}" = "${EZB_BOOL_TRUE}" ]] && ezb_log_error "Remote command failed, please check \"${data_file}\" for details"
        return 1
    else
        [[ "${status}" = "${EZB_BOOL_TRUE}" ]] && ezb_log_info "Remote command complete!"
        rm -f "${data_file}"
        return 0
    fi
}

function ezb_mssh_sudo_cmd() {
    if ! ezb_function_exist; then
        ezb_arg_set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ezb_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ezb_arg_set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ezb_arg_set --short "-p" --long "--password" --info "The root password" &&
        ezb_arg_set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ezb_arg_set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ezb_arg_set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" &&
        ezb_arg_set --short "-P" --long "--prompt" --required --default "${EZB_CHAR_SHARP}-${EZB_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZB_CHAR_SPACE}\" for \"app\" user" || return 0
    fi
    ezb_function_usage "${@}" && return
    local hosts && hosts="$(ezb_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ezb_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ezb_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ezb_arg_get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ezb_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ezb_arg_get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ezb_arg_get --short "-f" --long "--failure" --arguments "${@}")" &&
    local prompt && prompt="$(ezb_arg_get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    local cmd_md5=$(ezb_cmd_md5)
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local output=""; local md5_string=""
    local data_dir="${EZB_DIR_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    local host=""; for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        ezb_ssh_sudo_cmd --host "${host}" --user "${user}" --command "${command}" --password "${password}" \
                        --timeout "${timeout}" --prompt "${prompt}" --output "${output}"
        local exit_code="${?}"
        if  [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            ((++failure_count))
        fi
        if [[ "${print_failure}" = "${EZB_BOOL_TRUE}" ]] || [[ "${exit_code}" -eq 0 ]]; then
            md5_string=$(${cmd_md5} "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ezb_banner -m "Command Output"
    local host_count=0; local host=""; local key=""
    for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(tr "," " " <<< "${results[${key}]}" | wc -w | bc)
            host=$(cut -d "," -f 1 <<< "${results[${key}]}")
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if [[ "${stats}" = "${EZB_BOOL_TRUE}" ]]; then
        ezb_banner -m "Statistics"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
    fi
}

function ezb_mssh_cmd() {
    if ! ezb_function_exist; then
        ezb_arg_set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ezb_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ezb_arg_set --short "-u" --long "--user" --info "SSH user" &&
        ezb_arg_set --short "-p" --long "--port" --default "22" --info "SSH port" &&
        ezb_arg_set --short "-i" --long "--private-key" --info "Path to the SSH private key" &&
        ezb_arg_set --short "-t" --long "--timeout" --default "120" --info "The timeout seconds for each host" &&
        ezb_arg_set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ezb_arg_set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" || return 0
    fi
    ezb_function_usage "${@}" && return
    local hosts && hosts="$(ezb_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ezb_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ezb_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local port && port="$(ezb_arg_get --short "-p" --long "--port" --arguments "${@}")" &&
    local private_key && private_key="$(ezb_arg_get --short "-i" --long "--private-key" --arguments "${@}")" &&
    local timeout && timeout="$(ezb_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ezb_arg_get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ezb_arg_get --short "-f" --long "--failure" --arguments "${@}")" || return 1
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local cmd_timeout=$(ezb_cmd_timeout); local cmd_md5=$(ezb_cmd_md5)
    local output=""; local destination=""; local is_successful=""; local md5_string=""; local exit_code=0
    local data_dir="${EZB_DIR_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    local host=""; for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        if [[ -z "${user}" ]] || [[ "${user}" = "${USER}" ]]; then destination="${host}"; else destination="${user}@${host}"; fi
        is_successful=${EZB_BOOL_FALSE}
        if [[ -z "${private_key}" ]]; then
            ${cmd_timeout} "${timeout}" ssh -q -p "${port}" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" \
                -o "BatchMode=yes" "${destination}" "${command}" &> "${output}"
        else
            ${cmd_timeout} "${timeout}" ssh -q -p "${port}" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" \
                -o "BatchMode=yes" -i "${private_key}" "${destination}" "${command}" &> "${output}"
        fi
        exit_code="${?}"
        if [[ "${exit_code}" -eq 124 ]]; then
            [[ -z "${results[Timeout]}" ]] && results["Timeout"]="${host}" || results["Timeout"]+=",${host}"
            is_successful=${EZB_BOOL_FALSE}; ((++timeout_count))
        elif [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            is_successful=${EZB_BOOL_TRUE}; ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            is_successful=${EZB_BOOL_FALSE}; ((++failure_count))
        fi
        if [[ "${print_failure}" == "${EZB_BOOL_TRUE}" ]] || [[ "${is_successful}" == "${EZB_BOOL_TRUE}" ]]; then
            md5_string=$(${cmd_md5} "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ezb_banner -m "Command Output"
    local host_count=0; local host=""; local key=""
    for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(echo "${results[${key}]}" | tr "," " " | wc -w | bc)
            host=$(echo "${results[${key}]}" | cut -d "," -f 1)
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if [[ "${stats}" = "${EZB_BOOL_TRUE}" ]]; then
        ezb_banner -m "Statistics"
        echo "Timeout (${timeout_count}): ${results["Timeout"]}"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
        [[ "${failure_count}" -gt 0 ]] && ezb_log_info "Please check \"${data_dir}\" for details"
    fi
}
