###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "ssh" "expect" || return 1

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

function ez.md5 {
    if [[ "$(uname -s)" = "Darwin" ]]; then
        if ! hash "md5"; then ez.log.error "Not found \"md5\", please run \"brew install md5\""
        else echo "md5 -q"; fi
    else  # Linux
        if ! hash "md5sum"; then ez.log.error "Not found \"md5sum\", please run \"yum install md5sum\""
        else echo "md5sum"; fi
    fi
}

function ez.timeout {
    if [[ "$(uname -s)" = "Darwin" ]]; then
        if ! which "gtimeout" > "/dev/null"; then ez.log.error "Not found \"gtimeout\", please run \"brew install coreutils\""
        else echo "gtimeout"; fi
    else  # Linux
        if ! which "timeout" > "/dev/null"; then ez.log.error "Not found \"timeout\", please run \"yum install timeout\""
        else echo "timeout"; fi # Should be installed by default
    fi
}

function ez.ssh.agent.kill {
    local ssh_agent_pids=($(ps -ef | grep "ssh-agent" | grep -v "grep" | awk "{print \$2}"))
    echo "Killing PIDs: ${ssh_agent_pids[@]}"
    kill "${ssh_agent_pids[@]}"
}
function ez.ssh.port.forward {
    if ez.function.unregistered; then
        ez.argument.set --short "-lp" --long "--local-port" --info "Same as remote port if not specified" &&
        ez.argument.set --short "-ra" --long "--remote-address" --required --info "The remote IP or FQDN" &&
        ez.argument.set --short "-rp" --long "--remote-port" --info "Same as local port if not specified" &&
        ez.argument.set --short "-ru" --long "--remote-user" --required --default "${USER}" || return 1
    fi; ez.function.help "${@}" || return 0
    local local_port && local_port="$(ez.argument.get --short "-lp" --long "--local-port" --arguments "${@}")" &&
    local remote_address && remote_address="$(ez.argument.get --short "-ra" --long "--remote-address" --arguments "${@}")" &&
    local remote_port && remote_port="$(ez.argument.get --short "-rp" --long "--remote-port" --arguments "${@}")" &&
    local remote_user && remote_user="$(ez.argument.get --short "-ru" --long "--remote-user" --arguments "${@}")" || return 1
    if [[ -z "${remote_port}" && -n "${local_port}" ]]; then
        remote_port="${local_port}"
    elif [[ -z "${local_port}" && -n "${remote_port}" ]]; then
        local_port="${remote_port}"
    else
        ez.log.error "Port Not Found"; return 1
    fi
    ssh -R "${local_port}:${remote_address}:${remote_port}" "${remote_user}@${remote_address}"
}

function ez.ssh.oneliner {
    if ez.function.unregistered; then
        ez.argument.set --short "-h" --long "--hosts" --required --type "List" --info "The remote hostnames or IPs" &&
        ez.argument.set --short "-u" --long "--user" --required --default "${USER}" --info "The login user" &&
        ez.argument.set --short "-k" --long "--key" --info "The path to the ssh private key" &&
        ez.argument.set --short "-c" --long "--command" --required --info "Command to run" || return 1
    fi; ez.function.help "${@}" || return 0
    local hosts && hosts="$(ez.argument.get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" &&
    local command && command="$(ez.argument.get --short "-c" --long "--command" --arguments "${@}")" || return 1
    local host_list; ez.function.arguments.get_list "host_list" "${hosts}"
    local host output; for host in "${host_list[@]}"; do
        echo -n "${host} - "
        if [[ -z "${key}" ]]; then
            output="$(ssh "${EZ_SSH_OPTIONS[@]}" "${user}@${host}" "${command}" 2>&1)"
        else
            output="$(ssh "${EZ_SSH_OPTIONS[@]}" -i "${key}" "${user}@${host}" "${command}" 2>&1)"
        fi
        echo "${output//[[:cntrl:]]/|}"
    done
}

function ez.ssh.local_script {
    if ez.function.unregistered; then
        ez.argument.set --short "-t" --long "--timeout" --required --default 600 --info "SSH session timeout seconds" &&
        ez.argument.set --short "-h" --long "--hosts" --required --type "List" --info "The remote hostnames or IPs" &&
        ez.argument.set --short "-u" --long "--user" --required --default "${USER}" --info "The login user" &&
        ez.argument.set --short "-k" --long "--key" --info "The path to the ssh private key" &&
        ez.argument.set --short "-s" --long "--script" --required --info "The local script path" || return 1
    fi; ez.function.help "${@}" || return 0
    local timeout && timeout="$(ez.argument.get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local hosts && hosts="$(ez.argument.get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" &&
    local script && script="$(ez.argument.get --short "-s" --long "--script" --arguments "${@}")" || return 1
    local host_list; ez.function.arguments.get_list "host_list" "${hosts}"
    (( timeout += EZ_SSH_CONNECT_TIMEOUT ))
    local host; for host in "${host_list[@]}"; do
        echo "[${host}]"
        if [[ -z "${key}" ]]; then
            $(ez.timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" "${user}@${host}" "bash -s" < "${script}"
        else
            $(ez.timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -i "${key}" "${user}@${host}" "bash -s" < "${script}"
        fi
        echo
    done
}

function ez.ssh.local_function {
    if ez.function.unregistered; then
        ez.argument.set --short "-t" --long "--timeout" --required --default 600 --info "SSH session timeout seconds" &&
        ez.argument.set --short "-h" --long "--hosts" --required --type "List" --info "The remote host name" &&
        ez.argument.set --short "-u" --long "--user" --required --default "${USER}" --info "The login user" &&
        ez.argument.set --short "-k" --long "--key" --info "The path to the ssh private key" &&
        ez.argument.set --short "-f" --long "--function" --required --info "The local function name" &&
        ez.argument.set --short "-a" --long "--arguments" --type "List" --info "The argument list of the function" || return 1
    fi; ez.function.help "${@}" || return 0
    local timeout && timeout="$(ez.argument.get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local hosts && hosts="$(ez.argument.get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local key && key="$(ez.argument.get --short "-k" --long "--key" --arguments "${@}")" &&
    local func && func="$(ez.argument.get --short "-f" --long "--function" --arguments "${@}")" &&
    local arg_list && ez.function.arguments.get_list "arg_list" "$(ez.argument.get --short "-a" --long "--arguments" --arguments "${@}")" || return 1
    local script="${EZ_DIR_SCRIPTS}/${func}.sh" func_arg
    declare -f "${func}" > "${script}"
    echo -n "${func}" >> "${script}"; for func_arg in "${arg_list[@]}"; do echo -n " \"${func_arg}\"" >> "${script}"; done; echo >> "${script}"
    ez.ssh.local_script --hosts "${hosts[@]}" --user "${user}" --script "${script}" --key "${key}" --timeout "${timeout}"
}

function ez.ssh.mssh_cmd {
    if ez.function.unregistered; then
        ez.argument.set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez.argument.set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez.argument.set --short "-u" --long "--user" --info "SSH user" &&
        ez.argument.set --short "-p" --long "--port" --default "22" --info "SSH port" &&
        ez.argument.set --short "-i" --long "--private-key" --info "Path to the SSH private key" &&
        ez.argument.set --short "-t" --long "--timeout" --default "120" --info "The timeout seconds for each host" &&
        ez.argument.set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez.argument.set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" || return 1
    fi; ez.function.help "${@}" || return 0
    local hosts && hosts="$(ez.argument.get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ez.argument.get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-p" --long "--port" --arguments "${@}")" &&
    local private_key && private_key="$(ez.argument.get --short "-i" --long "--private-key" --arguments "${@}")" &&
    local timeout && timeout="$(ez.argument.get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ez.argument.get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ez.argument.get --short "-f" --long "--failure" --arguments "${@}")" || return 1
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
            $(ez.timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -p "${port}" "${destination}" "${command}" &> "${output}"
        else
            $(ez.timeout) "${timeout}" ssh "${EZ_SSH_OPTIONS[@]}" -p "${port}" -i "${private_key}" "${destination}" "${command}" &> "${output}"
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
        if ez.is_true "${print_failure}" || ez.is_true "${is_successful}"; then
            md5_string=$($(ez.md5) "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez.string.banner -m "Command Output"
    local host_count=0; local host=""
    local key; for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(echo "${results[${key}]}" | tr "," " " | wc -w | bc)
            host=$(echo "${results[${key}]}" | cut -d "," -f 1)
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if ez.is_true "${stats}"; then
        ez.string.banner -m "Statistics"
        echo "Timeout (${timeout_count}): ${results["Timeout"]}"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
        [[ "${failure_count}" -gt 0 ]] && ez.log.info "Please check \"${data_dir}\" for details"
    fi
}

# SSH and switch to root using the password, Save output in $save_to
# timeout=-1 means no timeout, if you give wrong "prompt", it will hang forever
function ez.ssh.sudo_cmd {
    if ez.function.unregistered; then
        ez.argument.set --short "-h" --long "--host" --required --info "The host to run the command on" &&
        ez.argument.set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez.argument.set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez.argument.set --short "-p" --long "--password" --info "The root password" &&
        ez.argument.set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez.argument.set --short "-s" --long "--status" --type "Flag" --info "Print status" &&
        ez.argument.set --short "-C" --long "--console" --type "Flag" --info "Print output to console" &&
        ez.argument.set --short "-o" --long "--output" --info "File path for output" &&
        ez.argument.set --short "-P" --long "--prompt" --required --default "${EZ_CHAR_SHARP}-${EZ_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZ_CHAR_SPACE}\" for \"app\" user" || return 1
    fi; ez.function.help "${@}" || return 0
    local host && host="$(ez.argument.get --short "-h" --long "--host" --arguments "${@}")" &&
    local command && command="$(ez.argument.get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ez.argument.get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ez.argument.get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local status && status="$(ez.argument.get --short "-s" --long "--status" --arguments "${@}")" &&
    local console && console="$(ez.argument.get --short "-C" --long "--console" --arguments "${@}")" &&
    local output && output="$(ez.argument.get --short "-o" --long "--output" --arguments "${@}")" &&
    local prompt && prompt="$(ez.argument.get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    local data_file; data_file="${EZ_DIR_DATA}/${FUNCNAME[0]}.${host}.${user}.$(date '+%F_%H-%M-%S')"; [[ -f "${data_file}" ]] && rm -f "${data_file}"
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
    local start_line; start_line=$(grep -n "${start_banner}" "${data_file}" | tail -1 | cut -d ":" -f 1)
    local end_line; end_line=$(grep -n "echo ${status_banner}" "${data_file}" | tail -1 | cut -d ":" -f 1)
    start_line=$((start_line+=2)); end_line=$((end_line-=1))
    ez.is_true "${console}" && sed -n "${start_line},${end_line}p" "${data_file}"
    [[ -n "${output}" ]] && sed -n "${start_line},${end_line}p" "${data_file}" > "${output}"
    local status_string; status_string=$(grep "${status_banner}" "${data_file}" | grep -v "echo") # get the $?
    if [[ "${status_string}" != "${status_banner}0${status_banner}"* ]]; then
        ez.is_true "${status}" && ez.log.error "Remote command failed, please check \"${data_file}\" for details"
        return 1
    else
        ez.is_true "${status}" && ez.log.info "Remote command complete!"
        rm -f "${data_file}"
        return 0
    fi
}

function ez.ssh.mssh_sudo_cmd {
    if ez.function.unregistered; then
        ez.argument.set --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez.argument.set --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez.argument.set --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez.argument.set --short "-p" --long "--password" --info "The root password" &&
        ez.argument.set --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez.argument.set --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez.argument.set --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" &&
        ez.argument.set --short "-P" --long "--prompt" --required --default "${EZ_CHAR_SHARP}-${EZ_CHAR_SPACE}" \
                    --info "Use \"\\\$${EZ_CHAR_SPACE}\" for \"app\" user" || return 1
    fi; ez.function.help "${@}" || return 0
    local hosts && hosts="$(ez.argument.get --short "-h" --long "--hosts" --arguments "${@}")" &&
    local command && command="$(ez.argument.get --short "-c" --long "--command" --arguments "${@}")" &&
    local user && user="$(ez.argument.get --short "-u" --long "--user" --arguments "${@}")" &&
    local password && password="$(ez.argument.get --short "-p" --long "--password" --arguments "${@}")" &&
    local timeout && timeout="$(ez.argument.get --short "-t" --long "--timeout" --arguments "${@}")" &&
    local stats && stats="$(ez.argument.get --short "-s" --long "--stats" --arguments "${@}")" &&
    local print_failure && print_failure="$(ez.argument.get --short "-f" --long "--failure" --arguments "${@}")" &&
    local prompt && prompt="$(ez.argument.get --short "-P" --long "--prompt" --arguments "${@}")" || return 1
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local output=""; local md5_string=""
    local data_dir="${EZ_DIR_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    local host; for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        ez.ssh.sudo_cmd --host "${host}" --user "${user}" --command "${command}" --password "${password}" \
                        --timeout "${timeout}" --prompt "${prompt}" --output "${output}"
        local exit_code="${?}"
        if  [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            ((++failure_count))
        fi
        if ez.is_true "${print_failure}" || [[ "${exit_code}" -eq 0 ]]; then
            md5_string=$($(ez.md5) "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez.string.banner -m "Command Output"
    local host_count=0 host=""
    local key; for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(tr "," " " <<< "${results[${key}]}" | wc -w | bc)
            host=$(cut -d "," -f 1 <<< "${results[${key}]}")
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if ez.is_true "${stats}"; then
        ez.string.banner -m "Statistics"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
    fi
}
