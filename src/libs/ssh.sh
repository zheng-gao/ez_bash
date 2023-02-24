###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "ssh" "expect" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
EZ_SSH_CONNECT_TIMEOUT=10
EZ_SSH_OPTIONS=(
    "-o" "BatchMode=yes"
    "-o" "ConnectTimeout=${EZ_SSH_CONNECT_TIMEOUT}"
    "-o" "LogLevel=error"
    "-o" "StrictHostKeyChecking=no"
    "-o" "PasswordAuthentication=no"
)

function ez_ssh_local_script {
    if ez_function_unregistered; then
        ez_arg_set --short "-t" --long "--timeout" --required --default 600 --info "SSH session timeout seconds" &&
        ez_arg_set --short "-h" --long "--hosts" --required --type "List" --info "The remote hostnames or IPs" &&
        ez_arg_set --short "-u" --long "--user" --required --default "${USER}" --info "The login user" &&
        ez_arg_set --short "-k" --long "--key" --info "The path to the ssh private key" &&
        ez_arg_set --short "-s" --long "--script" --required --info "The local script path" || return 1
    fi
    ez_function_usage "${@}" && return
    local timeout && timeout="$(ez_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local hosts && hosts="$(ez_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local user && user="$(ez_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local key && key="$(ez_arg_get --short "-k" --long "--key" --arguments "${@}")" &&
    local script && script="$(ez_arg_get --short "-s" --long "--script" --arguments "${@}")" || return 1
    local host_list; ez_function_get_list "host_list" "${hosts}"
    (( timeout += EZ_SSH_CONNECT_TIMEOUT ))
    local host; for host in "${host_list[@]}"; do
        echo "[${host}]"
        if [[ -z "${key}" ]]; then
            $(ez_timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" "${user}@${host}" "bash -s" < "${script}"
        else
            $(ez_timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -i "${key}" "${user}@${host}" "bash -s" < "${script}"
        fi
        echo
    done
}

function ez_ssh_local_function {
    if ez_function_unregistered; then
        ez_arg_set --short "-t" --long "--timeout" --required --default 600 --info "SSH session timeout seconds" &&
        ez_arg_set --short "-h" --long "--hosts" --required --type "List" --info "The remote host name" &&
        ez_arg_set --short "-u" --long "--user" --required --default "${USER}" --info "The login user" &&
        ez_arg_set --short "-k" --long "--key" --info "The path to the ssh private key" &&
        ez_arg_set --short "-f" --long "--function" --required --info "The local function name" &&
        ez_arg_set --short "-a" --long "--arguments" --type "List" --info "The argument list of the function" || return 1
    fi
    ez_function_usage "${@}" && return
    local timeout && timeout="$(ez_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local hosts && hosts="$(ez_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local user && user="$(ez_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local key && key="$(ez_arg_get --short "-k" --long "--key" --arguments "${@}")" &&
    local func && func="$(ez_arg_get --short "-f" --long "--function" --arguments "${@}")" &&
    local args && args="$(ez_arg_get --short "-a" --long "--arguments" --arguments "${@}")" || return 1
    local arg_list; ez_function_get_list "arg_list" "${args}"
    local args_str="$(ez_double_quote "${arg_list[@]}")"
    local script="${EZ_DIR_SCRIPTS}/${func}.sh"
    declare -f "${func}" > "${script}"
    echo "${func} ${args_str}" >> "${script}"
    ez_ssh_local_script --hosts "${hosts[@]}" --user "${user}" --script "${script}" --key "${key}" --timeout "${timeout}"
}

function ez_mssh_cmd {
    if ez_function_unregistered; then
        ez_arg_set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_arg_set --short "-u" --long "--user" --info "SSH user" &&
        ez_arg_set --short "-p" --long "--port" --default "22" --info "SSH port" &&
        ez_arg_set --short "-i" --long "--private-key" --info "Path to the SSH private key" &&
        ez_arg_set --short "-t" --long "--timeout" --default "120" --info "The timeout seconds for each host" &&
        ez_arg_set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez_arg_set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" || return 1
    fi
    ez_function_usage "${@}" && return
    local hosts && hosts="$(ez_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ez_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local port && port="$(ez_arg_get --short "-p" --long "--port" --arguments "${@}")" &&
    local private_key && private_key="$(ez_arg_get --short "-i" --long "--private-key" --arguments "${@}")" &&
    local timeout && timeout="$(ez_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ez_arg_get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ez_arg_get --short "-f" --long "--failure" --arguments "${@}")" || return 1
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local output=""; local destination=""; local is_successful=""; local md5_string=""; local exit_code=0
    local data_dir="${EZ_DIR_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    local host; for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        if [[ -z "${user}" ]] || [[ "${user}" = "${USER}" ]]; then destination="${host}"; else destination="${user}@${host}"; fi
        is_successful=${EZ_FALSE}
        if [[ -z "${private_key}" ]]; then
            $(ez_timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -p "${port}" "${destination}" "${command}" &> "${output}"
        else
            $(ez_timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -p "${port}" -i "${private_key}" "${destination}" "${command}" &> "${output}"
        fi
        exit_code="${?}"
        if [[ "${exit_code}" -eq 124 ]]; then
            [[ -z "${results[Timeout]}" ]] && results["Timeout"]="${host}" || results["Timeout"]+=",${host}"
            is_successful=${EZ_FALSE}; ((++timeout_count))
        elif [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            is_successful=${EZ_TRUE}; ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            is_successful=${EZ_FALSE}; ((++failure_count))
        fi
        if ez_is_true "${print_failure}" || ez_is_true "${is_successful}"; then
            md5_string=$($(ez_md5) "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez_banner -m "Command Output"
    local host_count=0; local host=""
    local key; for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(echo "${results[${key}]}" | tr "," " " | wc -w | bc)
            host=$(echo "${results[${key}]}" | cut -d "," -f 1)
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if ez_is_true "${stats}"; then
        ez_banner -m "Statistics"
        echo "Timeout (${timeout_count}): ${results["Timeout"]}"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
        [[ "${failure_count}" -gt 0 ]] && ez_log_info "Please check \"${data_dir}\" for details"
    fi
}

# SSH and switch to root using the password, Save output in $save_to
# timeout=-1 means no timeout, if you give wrong "prompt", it will hang forever
function ez_ssh_sudo_cmd {
    if ez_function_unregistered; then
        ez_arg_set --short "-h" --long "--host" --required --info "The host to run the command on" &&
        ez_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_arg_set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez_arg_set --short "-p" --long "--password" --info "The root password" &&
        ez_arg_set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez_arg_set --short "-s" --long "--status" --type "Flag" --info "Print status" &&
        ez_arg_set --short "-C" --long "--console" --type "Flag" --info "Print output to console" &&
        ez_arg_set --short "-o" --long "--output" --info "File path for output" &&
        ez_arg_set --short "-P" --long "--prompt" --required --default "${EZ_CHAR_SHARP}-${EZ_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZ_CHAR_SPACE}\" for \"app\" user" || return 1
    fi
    ez_function_usage "${@}" && return
    local host && host="$(ez_arg_get --short "-h" --long "--host" --arguments "${@}")" &&
    local command && command="$(ez_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ez_arg_get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ez_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local status && status="$(ez_arg_get --short "-s" --long "--status" --arguments "${@}")" &&
    local console && console="$(ez_arg_get --short "-C" --long "--console" --arguments "${@}")" &&
    local output && output="$(ez_arg_get --short "-o" --long "--output" --arguments "${@}")" &&
    local prompt && prompt="$(ez_arg_get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    local data_file="${EZ_DIR_DATA}/${FUNCNAME[0]}.${host}.${user}.$(date '+%F_%H-%M-%S')"; [[ -f "${data_file}" ]] && rm -f "${data_file}"
    [[ "${user}" = "root" ]] && user=""; [[ "${user}" = "${USER}" ]] && user="-"
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    prompt=$(sed "s/${EZ_CHAR_SPACE}/ /g" <<< "${prompt}")
    prompt=$(sed "s/${EZ_CHAR_SHARP}-/#/g" <<< "${prompt}")
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
    ez_is_true "${console}" && sed -n "${start_line},${end_line}p" "${data_file}"
    [[ -n "${output}" ]] && sed -n "${start_line},${end_line}p" "${data_file}" > "${output}"
    local status_string=$(grep "${status_banner}" "${data_file}" | grep -v "echo") # get the $?
    if [[ "${status_string}" != "${status_banner}0${status_banner}"* ]]; then
        ez_is_true "${status}" && ez_log_error "Remote command failed, please check \"${data_file}\" for details"
        return 1
    else
        ez_is_true "${status}" && ez_log_info "Remote command complete!"
        rm -f "${data_file}"
        return 0
    fi
}

function ez_mssh_sudo_cmd {
    if ez_function_unregistered; then
        ez_arg_set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez_arg_set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_arg_set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez_arg_set --short "-p" --long "--password" --info "The root password" &&
        ez_arg_set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez_arg_set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez_arg_set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" &&
        ez_arg_set --short "-P" --long "--prompt" --required --default "${EZ_CHAR_SHARP}-${EZ_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZ_CHAR_SPACE}\" for \"app\" user" || return 1
    fi
    ez_function_usage "${@}" && return
    local hosts && hosts="$(ez_arg_get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ez_arg_get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez_arg_get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ez_arg_get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ez_arg_get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ez_arg_get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ez_arg_get --short "-f" --long "--failure" --arguments "${@}")" &&
    local prompt && prompt="$(ez_arg_get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local output=""; local md5_string=""
    local data_dir="${EZ_DIR_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    local host; for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        ez_ssh_sudo_cmd --host "${host}" --user "${user}" --command "${command}" --password "${password}" \
                        --timeout "${timeout}" --prompt "${prompt}" --output "${output}"
        local exit_code="${?}"
        if  [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            ((++failure_count))
        fi
        if ez_is_true "${print_failure}" || [[ "${exit_code}" -eq 0 ]]; then
            md5_string=$($(ez_md5) "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez_banner -m "Command Output"
    local host_count=0 host=""
    local key; for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(tr "," " " <<< "${results[${key}]}" | wc -w | bc)
            host=$(cut -d "," -f 1 <<< "${results[${key}]}")
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if ez_is_true "${stats}"; then
        ez_banner -m "Statistics"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
    fi
}
