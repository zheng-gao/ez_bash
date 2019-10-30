###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

# SSH and switch to root using the password, Save output in $save_to
# timeout=-1 means no timeout, if you give wrong "prompt", it will hang forever
function ez_ssh_sudo_cmd() {
    if ! ez_function_exist; then
        ez_set_argument --short "-h" --long "--host" --required --info "The host to run the command on" &&
        ez_set_argument --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_set_argument --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez_set_argument --short "-p" --long "--password" --info "The root password" &&
        ez_set_argument --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez_set_argument --short "-s" --long "--status" --type "Flag" --info "Print status" &&
        ez_set_argument --short "-C" --long "--console" --type "Flag" --info "Print output to console" &&
        ez_set_argument --short "-o" --long "--output" --info "File path for output" &&
        ez_set_argument --short "-P" --long "--prompt" --required --default "${EZ_BASH_SHARP}-${EZ_BASH_SPACE}" --info "Use \"\\\$${EZ_BASH_SPACE}\" for \"app\" user" ||
        return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local host="$(ez_get_argument --short "-h" --long "--host" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local command="$(ez_get_argument --short "-c" --long "--command" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local user="$(ez_get_argument --short "-u" --long "--user" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local password="$(ez_get_argument --short "-p" --long "--password" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local timeout="$(ez_get_argument --short "-t" --long "--timeout" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local status="$(ez_get_argument --short "-s" --long "--status" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local console="$(ez_get_argument --short "-C" --long "--console" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local output="$(ez_get_argument --short "-o" --long "--output" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local prompt="$(ez_get_argument --short "-P" --long "--prompt" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local data_file="${EZ_BASH_DATA}/${FUNCNAME[0]}.${host}.${user}.$(date '+%F_%H-%M-%S')"; [[ -f "${data_file}" ]] && rm -f "${data_file}"
    [[ "${user}" = "root" ]] && user=""; [[ "${user}" = "${USER}" ]] && user="-"
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    prompt=$(sed "s/${EZ_BASH_SPACE}/ /g" <<< "${prompt}")
    prompt=$(sed "s/${EZ_BASH_SHARP}-/#/g" <<< "${prompt}")
    if ! ez_check_cmd "expect"; then ez_log_error "Command \"expect\" Not Found!"; return 1; fi
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
    [[ "${console}" = "${EZ_BASH_BOOL_TRUE}" ]] && sed -n "${start_line},${end_line}p" "${data_file}"
    [[ -n "${output}" ]] && sed -n "${start_line},${end_line}p" "${data_file}" > "${output}"
    local status_string=$(grep "${status_banner}" "${data_file}" | grep -v "echo") # get the $?
    if [[ "${status_string}" != "${status_banner}0${status_banner}"* ]]; then
        [[ "${status}" = "${EZ_BASH_BOOL_TRUE}" ]] && ez_log_error "Remote command failed, please check \"${data_file}\" for details"
        return 1
    else
        [[ "${status}" = "${EZ_BASH_BOOL_TRUE}" ]] && ez_log_info "Remote command complete!"
        rm -f "${data_file}"
        return 0
    fi
}

function ez_mssh_sudo_cmd() {
    if ! ez_function_exist; then
        ez_set_argument --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez_set_argument --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_set_argument --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez_set_argument --short "-p" --long "--password" --info "The root password" &&
        ez_set_argument --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez_set_argument --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez_set_argument --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" &&
        ez_set_argument --short "-P" --long "--prompt" --required --default "${EZ_BASH_SHARP}-${EZ_BASH_SPACE}" --info "Use \"\\\$${EZ_BASH_SPACE}\" for \"app\" user" ||
        return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local hosts="$(ez_get_argument --short "-h" --long "--hosts" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local command="$(ez_get_argument --short "-c" --long "--command" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local user="$(ez_get_argument --short "-u" --long "--user" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local password="$(ez_get_argument --short "-p" --long "--password" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local timeout="$(ez_get_argument --short "-t" --long "--timeout" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local stats="$(ez_get_argument --short "-s" --long "--stats" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local print_failure="$(ez_get_argument --short "-f" --long "--failure" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local prompt="$(ez_get_argument --short "-P" --long "--prompt" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    local cmd_md5=$(ez_get_cmd_md5)
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local output=""; local md5_string=""
    local data_dir="${EZ_BASH_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    for host in $(echo "${hosts}" | sed "s/,/ /g"); do
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
        if [[ "${print_failure}" = "${EZ_BASH_BOOL_TRUE}" ]] || [[ "${exit_code}" -eq 0 ]]; then
            md5_string=$(${cmd_md5} "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez_print_banner -m "Command Output"
    local host_count=0; local host=""
    for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(tr "," " " <<< "${results[${key}]}" | wc -w | bc)
            host=$(cut -d "," -f 1 <<< "${results[${key}]}")
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if [[ "${stats}" = "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_banner -m "Statistics"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
    fi
}

function ez_mssh_cmd() {
    if ! ez_function_exist; then
        ez_set_argument --short "-h" --long "--hosts" --required --info "Separated by comma" &&
        ez_set_argument --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take the 1st word" &&
        ez_set_argument --short "-u" --long "--user" --info "SSH user" &&
        ez_set_argument --short "-p" --long "--port" --default "22" --info "SSH port" &&
        ez_set_argument --short "-i" --long "--private-key" --info "Path to the SSH private key" &&
        ez_set_argument --short "-t" --long "--timeout" --default "120" --info "The timeout seconds for each host" &&
        ez_set_argument --short "-s" --long "--stats" --type "Flag" --info "Print the stats" &&
        ez_set_argument --short "-f" --long "--failure" --type "Flag" --info "Print the output of the failed cases" ||
        return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local hosts="$(ez_get_argument --short "-h" --long "--hosts" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local command="$(ez_get_argument --short "-c" --long "--command" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local user="$(ez_get_argument --short "-u" --long "--user" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local port="$(ez_get_argument --short "-p" --long "--port" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local private_key="$(ez_get_argument --short "-i" --long "--private-key" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local timeout="$(ez_get_argument --short "-t" --long "--timeout" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local stats="$(ez_get_argument --short "-s" --long "--stats" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local print_failure="$(ez_get_argument --short "-f" --long "--failure" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    declare -A results
    local timeout_count=0; results["Timeout"]=""
    local success_count=0; results["Success"]=""
    local failure_count=0; results["Failure"]=""
    local cmd_timeout=$(ez_get_cmd_timeout); local cmd_md5=$(ez_get_cmd_md5)
    local output=""; local destination=""; local is_successful=""; local md5_string=""; local exit_code=0
    local data_dir="${EZ_BASH_DATA}/${FUNCNAME[0]}"; [[ ! -d "${data_dir}" ]] && mkdir -p "${data_dir}"
    for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        output="${data_dir}/${host}"
        if [[ -z "${user}" ]] || [[ "${user}" = "${USER}" ]]; then destination="${host}"; else destination="${user}@${host}"; fi
        is_successful=${EZ_BASH_BOOL_FALSE}
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
            is_successful=${EZ_BASH_BOOL_FALSE}; ((++timeout_count))
        elif [[ "${exit_code}" -eq 0 ]]; then
            [[ -z "${results[Success]}" ]] && results["Success"]="${host}" || results["Success"]+=",${host}"
            is_successful=${EZ_BASH_BOOL_TRUE}; ((++success_count))
        else
            [[ -z "${results[Failure]}" ]] && results["Failure"]="${host}" || results["Failure"]+=",${host}"
            is_successful=${EZ_BASH_BOOL_FALSE}; ((++failure_count))
        fi
        if [[ "${print_failure}" == "${EZ_BASH_BOOL_TRUE}" ]] || [[ "${is_successful}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            md5_string=$(${cmd_md5} "${output}" | cut -f 1)
            [[ -z "${results[${md5_string}]}" ]] && results["${md5_string}"]="${host}" || results["${md5_string}"]+=",${host}"
        fi
    done
    ez_print_banner -m "Command Output"
    local host_count=0; local host=""
    for key in "${!results[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            host_count=$(echo "${results[${key}]}" | tr "," " " | wc -w | bc)
            host=$(echo "${results[${key}]}" | cut -d "," -f 1)
            echo "${results[${key}]} (${host_count}):"
            cat "${data_dir}/${host}"; echo
        fi
    done
    if [[ "${stats}" = "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_banner -m "Statistics"
        echo "Timeout (${timeout_count}): ${results["Timeout"]}"
        echo "Failure (${failure_count}): ${results["Failure"]}"
        echo "Success (${success_count}): ${results["Success"]}"; echo
        [[ "${failure_count}" -gt 0 ]] && ez_log_info "Please check \"${data_dir}\" for details"
    fi
}
