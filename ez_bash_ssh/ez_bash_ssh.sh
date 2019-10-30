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
        ez_set_argument --short "-c" --long "--command" --required --info "Must be quoted otherwise it only take one word" &&
        ez_set_argument --short "-u" --long "--user" --required --default "root" --info "Switch to a user" &&
        ez_set_argument --short "-p" --long "--password" --info "The root password" &&
        ez_set_argument --short "-t" --long "--timeout" --default "10" --info "Connection timeout seconds, negative value means no timeout" &&
        ez_set_argument --short "-s" --long "--status" --type "Flag" --info "Print status" &&
        ez_set_argument --short "-C" --long "--console" --type "Flag" --info "Print output to console" &&
        ez_set_argument --short "-o" --long "--output" --info "File path for output" &&
        ez_set_argument --short "-P" --long "--prompt" --required --default "${EZ_BASH_SHARP}-${EZ_BASH_SPACE}" --info "For \"app\" user use \"\\\$${EZ_BASH_SPACE}\"" ||
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
    [[ "${user}" = "root" ]] && user=""
    [[ "${user}" = "${USER}" ]] && user="-"
    [[ -z "${password}" ]] && read -s -p "Sudo Password: " password && echo
    prompt=$(sed "s/${EZ_BASH_SPACE}/ /g" <<< "${prompt}")
    prompt=$(sed "s/${EZ_BASH_SHARP}-/#/g" <<< "${prompt}")
    if [[ $(ez_command_check -c "expect") = "${EZ_BASH_BOOL_FALSE}" ]]; then ez_log_error "Command \"expect\" Not Found!"; return 1; fi
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
        return 0
    fi
}

function ez_mssh_cmd() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_mssh_cmd" -d "Run ssh command on multiple hosts")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--dir" -d "Directory to save results, default = /var/tmp/ez_mssh_cmd")
    usage_string+=$(ez_build_usage -o "add" -a "-h|--hosts" -d "The hosts should be separated by \",\"")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--port" -d "SSH Port, default = 22")
    usage_string+=$(ez_build_usage -o "add" -a "-u|--user" -d "The user to access the hosts, default = ${USER}")
    usage_string+=$(ez_build_usage -o "add" -a "-i|--private-key" -d "The ssh private key file path")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--cmd" -d "The command string, must be quoted otherwise it only take one word")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--timeout" -d "The timeout seconds for each host, default = 120")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--failure" -d "Print the output of the failed cases")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--stats" -d "Print the stats")
    if [[ "${1}" == "" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local dir="/var/tmp/ez_mssh_cmd"
    local port=""
    local hosts=""
    local user="${USER}"
    local private_key=""
    local timeout=""
    local failure=${EZ_BASH_BOOL_FALSE}
    local stats=${EZ_BASH_BOOL_FALSE}
    local cmd=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--dir") shift; dir=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-h" | "--hosts") shift; hosts=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--port") shift; port=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-u" | "--user") shift; user=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--cmd") shift; cmd=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-i" | "--private-key") shift; private_key=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-t" | "--timeout") shift; timeout=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-f" | "--failure") shift; failure=${EZ_BASH_BOOL_TRUE}; ;;
            "-s" | "--stats") shift; stats=${EZ_BASH_BOOL_TRUE}; ;;
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${hosts}" == "" ]]; then ez_print_log -l ERROR -m "Hostnames cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${cmd}" == "" ]]; then ez_print_log -l ERROR -m "Command cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${timeout}" == "" ]]; then timeout=120; fi
    if [[ "${port}" == "" ]]; then port=22; fi
    if [ ! -d "${dir}" ]; then mkdir -p "${dir}"; fi
    local timeout_cmd=$(ez_get_timeout_cmd)
    local md5_cmd=$(ez_get_md5_cmd)
    declare -A result_map
    local timeout_count=0; result_map["Timeout"]=""
    local success_count=0; result_map["Success"]=""
    local failure_count=0; result_map["Failure"]=""
    for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        local log_file="${dir}/${host}"
        local destination="${user}@${host}"
        if [[ "${user}" == "" ]]; then destination="${host}"; fi
        local is_successful=${EZ_BASH_BOOL_FALSE}
        if [[ "${private_key}" == "" ]]; then
            ${timeout_cmd} "${timeout}" ssh -q -p "${port}" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" -o "BatchMode=yes" "${destination}" "${cmd}" &> "${log_file}"
        else
            ${timeout_cmd} "${timeout}" ssh -q -p "${port}" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" -o "BatchMode=yes" -i "${private_key}" "${destination}" "${cmd}" &> "${log_file}"
        fi
        local exit_code=${?}
        if [ ${exit_code} -eq 124 ]; then
            if [[ ${result_map["Timeout"]} == "" ]]; then
                result_map["Timeout"]="${host}"
            else
                result_map["Timeout"]+=",${host}"
            fi
            is_successful=${EZ_BASH_BOOL_FALSE}
            ((++timeout_count))
        elif [ ${exit_code} -eq 0 ]; then
            if [[ ${result_map["Success"]} == "" ]]; then
                result_map["Success"]="${host}"
            else
                result_map["Success"]+=",${host}"
            fi
            is_successful=${EZ_BASH_BOOL_TRUE}
            ((++success_count))
        else
            if [[ ${result_map["Failure"]} == "" ]]; then
                result_map["Failure"]="${host}"
            else
                result_map["Failure"]+=",${host}"
            fi
            ((++failure_count))
            is_successful=${EZ_BASH_BOOL_FALSE}
        fi
        if [[ "${failure}" == "${EZ_BASH_BOOL_TRUE}" ]] || [[ "${is_successful}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            local md5_string=$(${md5_cmd} "${log_file}" | cut -f 1)
            if [[ "${result_map[${md5_string}]}" == "" ]]; then
                result_map[${md5_string}]="${host}"
            else
                result_map[${md5_string}]+=",${host}"
            fi
        fi
    done
    ez_print_banner -m "Command Output"
    for key in "${!result_map[@]}"; do
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            local hosts_count=$(echo "${result_map["${key}"]}" | tr "," " " | wc -w | bc)
            local host_for_log=$(echo "${result_map["${key}"]}" | cut -d "," -f 1)
            local result=$(cat ${dir}/${host_for_log})
            echo "${result_map["${key}"]} (${hosts_count}):"
            echo "${result}"
        fi
    done
    if [[ "${stats}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_banner -m "Statistics"
        echo "Timeout (${timeout_count}): ${result_map["Timeout"]}"
        echo "Failure (${failure_count}): ${result_map["Failure"]}"
        echo "Success (${success_count}): ${result_map["Success"]}"
    fi
}

function ez_mssh_sudo_cmd() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_mssh_sudo_cmd" -d "Run ssh sudo command on multiple hosts")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--dir" -d "Directory to save results, default = /var/tmp/ez_mssh_sudo_cmd")
    usage_string+=$(ez_build_usage -o "add" -a "-h|--hosts" -d "The hosts should be separated by \",\"")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--cmd" -d "The command string, must be quoted otherwise it only take one word")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--timeout" -d "The timeout seconds for each host, default = 120")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--failure" -d "Print the output of the failed cases")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--stats" -d "Print the stats")
    usage_string+=$(ez_build_usage -o "add" -a "--switch-user" -d "Switch to a user, default = root")
    usage_string+=$(ez_build_usage -o "add" -a "--sudo-pwd" -d "The root user password")
    usage_string+=$(ez_build_usage -o "add" -a "--prompt" -d "The switch user's prompt, default = \"#${EZ_BASH_SPACE}\", for \"app\" user use \"\\\$${EZ_BASH_SPACE}\"")
    if [[ "${1}" == "" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local dir="/var/tmp/ez_mssh_sudo_cmd"
    local hosts=""
    local timeout=""
    local failure=${EZ_BASH_BOOL_FALSE}
    local stats=${EZ_BASH_BOOL_FALSE}
    local cmd=""
    local switch_user="root"
    local sudo_pwd=""
    local prompt=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--dir") shift; dir=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-h" | "--hosts") shift; hosts=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--cmd") shift; cmd=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-t" | "--timeout") shift; timeout=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-f" | "--failure") shift; failure=${EZ_BASH_BOOL_TRUE}; ;;
            "-s" | "--stats") shift; stats=${EZ_BASH_BOOL_TRUE}; ;;
            "--switch-user") shift; switch_user=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--sudo-pwd") shift; sudo_pwd=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--prompt") shift; prompt=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${sudo_pwd}" == "" ]]; then read -s -p "Sudo Password: " sudo_pwd; echo; fi
    if [[ "${prompt}" == "" ]]; then prompt="#${EZ_BASH_SPACE}"; fi
    if [[ "${hosts}" == "" ]]; then ez_print_log -l ERROR -m "Hostnames cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${cmd}" == "" ]]; then ez_print_log -l ERROR -m "Command cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${timeout}" == "" ]]; then timeout=10; fi
    if [ ! -d "${dir}" ]; then mkdir -p "${dir}"; fi
    local md5_cmd=$(ez_get_md5_cmd)
    declare -A result_map
    local timeout_count=0; result_map["Timeout"]=""
    local success_count=0; result_map["Success"]=""
    local failure_count=0; result_map["Failure"]=""
    for host in $(echo "${hosts}" | sed "s/,/ /g"); do
        local log_file="${dir}/${host}"
        local log_file_tmp="${log_file}.tmp"
        local destination="${user}@${host}"
        if [[ "${user}" == "" ]]; then destination="${host}"; fi
        local is_successful=${EZ_BASH_BOOL_FALSE}
        ez_ssh_sudo_cmd --host "${host}" --user "${switch_user}" --command "${cmd}" --password "${sudo_pwd}" \
                        --timeout "${timeout}" --prompt "${prompt}" --output "${log_file}"
        local exit_code=${?}
        # echo "${host}: ${exit_code}"
        if  [ ${exit_code} -eq 0 ]; then
            if [[ ${result_map["Success"]} == "" ]]; then
                result_map["Success"]="${host}"
            else
                result_map["Success"]+=",${host}"
            fi
            is_successful=${EZ_BASH_BOOL_TRUE}
            ((++success_count))
        else
            if [[ ${result_map["Failure"]} == "" ]]; then
                result_map["Failure"]="${host}"
            else
                result_map["Failure"]+=",${host}"
            fi
            ((++failure_count))
            is_successful=${EZ_BASH_BOOL_FALSE}
        fi
        if [[ "${failure}" == "${EZ_BASH_BOOL_TRUE}" ]] || [[ "${is_successful}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            local md5_string=$(${md5_cmd} "${log_file}" | cut -f 1)
            if [[ "${result_map[${md5_string}]}" == "" ]]; then
                result_map["${md5_string}"]="${host}"
            else
                result_map["${md5_string}"]+=",${host}"
            fi
        fi
    done
    ez_print_banner -m "Command Output"
    for key in "${!result_map[@]}"; do
        # echo "key=${key}"
        if [[ "${key}" != "Timeout" ]] && [[ "${key}" != "Failure" ]] && [[ "${key}" != "Success" ]]; then
            local hosts_count=$(echo "${result_map["${key}"]}" | tr "," " " | wc -w | bc)
            local host_for_log=$(echo "${result_map["${key}"]}" | cut -d "," -f 1)
            local result=$(cat ${dir}/${host_for_log})
            echo "${result_map["${key}"]} (${hosts_count}):"
            echo "${result}"
        fi
    done
    if [[ "${stats}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_banner -m "Statistics"
        echo "Failure (${failure_count}): ${result_map["Failure"]}"
        echo "Success (${success_count}): ${result_map["Success"]}"
    fi
}
