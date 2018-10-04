#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_ssh.sh"
if [[ "${0}" != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        echo "[EZ-BASH][ERROR] ${THIS_SCRIPT_NAME} is not runnable!"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"
        exit 1
    fi
fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if ! source "${EZ_BASH_HOME}/ez_bash_log/ez_bash_log.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_time/ez_bash_time.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_variables/ez_bash_variables.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_sanity_check/ez_bash_sanity_check.sh"; then exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

# SSH and switch to root using the password, Save output in $save_to
# timeout=-1 means no time out, if you give wrong "prompt", it will hang forever
function ez_ssh_sudo_cmd() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_ssh_sudo_cmd" -d "Run sudo command remotely, will hang forever if given the wrong prompt")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--log" -d "Save raw log to a file, default = /var/tmp/ez_ssh_sudo_cmd.log")
    usage_string+=$(ez_build_usage -o "add" -a "-h|--host" -d "The host to run the command on")
    usage_string+=$(ez_build_usage -o "add" -a "-u|--user" -d "Switch to a user, default = root")
    usage_string+=$(ez_build_usage -o "add" -a "-p|--pwd" -d "The root user password")
    usage_string+=$(ez_build_usage -o "add" -a "-c|--cmd" -d "The command string, must be quoted otherwise it only take one word")
    usage_string+=$(ez_build_usage -o "add" -a "-t|--timeout" -d "The timeout seconds, default = 120")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--status" -d "Print Status")
    usage_string+=$(ez_build_usage -o "add" -a "-oc|--output-console" -d "Print output to console")
    usage_string+=$(ez_build_usage -o "add" -a "-of|--output-file" -d "Print output to file")
    usage_string+=$(ez_build_usage -o "add" -a "--prompt" -d "The user's prompt, default = \"#${EZ_BASH_SPACE}\", for \"app\" user use \"\$${EZ_BASH_SPACE}\"")
    if [[ "${1}" == "" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${1}" == "-h" ]] && [[ "${2}" == "" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local log_file="/var/tmp/ez_ssh_sudo_cmd.log"
    local host=""
    local user="root"
    local prompt=""
    local pwd=""
    local timeout=""
    local status=${EZ_BASH_BOOL_FALSE}
    local output_console=${EZ_BASH_BOOL_FALSE}
    local output_file=""
    local cmd=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-l" | "--log") shift; log_file=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-h" | "--host") shift; host=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-u" | "--user") shift; user=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-p" | "--pwd") shift; pwd=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "--prompt") shift; prompt=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-t" | "--timeout") shift; timeout=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-c" | "--cmd") shift; cmd=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--status") shift; status=${EZ_BASH_BOOL_TRUE}; ;;
            "-oc" | "--output-console") shift; output_console=${EZ_BASH_BOOL_TRUE}; ;;
            "-of" | "--output-file") shift; output_file=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${host}" == "" ]]; then ez_print_log -l ERROR -m "Hostname cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${cmd}" == "" ]]; then ez_print_log -l ERROR -m "Command cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${pwd}" == "" ]]; then read -s -p "Password: " pwd; echo; fi
    if [[ "${timeout}" == "" ]]; then timeout=120; fi
    if [[ "${prompt}" == "" ]]; then prompt="#${EZ_BASH_SPACE}"; fi
    if [[ "${user}" == "root" ]]; then user=""; fi
    if [[ $(ez_command_check -c "expect") == "${EZ_BASH_BOOL_FALSE}" ]]; then
        ez_print_log -l ERROR -m "Command \"expect\" Not Found!"; return 1
    fi
    prompt=$(echo "${prompt}" | sed "s/${EZ_BASH_SPACE}/ /g")
    echo > "${log_file}"
    {
        expect << EOF
        set timeout ${timeout}
        spawn ssh -o StrictHostKeyChecking=no ${host}
        send "sudo su - ${user}\r"; expect "assword"
        send -- "${pwd}\r"; expect "${prompt}"
        send "echo EZ-BASHCommandStart\r"; expect "${prompt}"
        send "${cmd}\r"; expect "${prompt}"
        send "echo EZ-BASHCommandStatus=$\?EZ-BASHCommandStatus\r"; expect "${prompt}"
        send "echo\r"; expect "${prompt}" # make sure the prompt is present
EOF
    } &> "${log_file}"
    local start_line=$(grep -n EZ-BASHCommandStart ${log_file} | tail -1 | cut -d ":" -f 1)
    local end_line=$(grep -n "echo EZ-BASHCommandStatus=" ${log_file} | tail -1 | cut -d ":" -f 1)
    start_line=$((start_line+=2))
    end_line=$((end_line-=1))
    if [[ "${output_console}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        sed -n "${start_line},${end_line}p" "${log_file}"
    fi
    if [[ "${output_file}" != "" ]]; then
        sed -n "${start_line},${end_line}p" "${log_file}" > "${output_file}"
    fi
    local status_string=$(grep "CommandStatus=" "${log_file}" | grep -v "echo") # get the $?
    if [[ "${status_string}" != "EZ-BASHCommandStatus=0EZ-BASHCommandStatus"* ]]; then
        if [[ "${status}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
            ez_print_log -l ERROR -m "Remote Command Failed, Please check \"${log_file}\" for details"
        fi
        return 1
    fi
    if [[ "${status}" == "${EZ_BASH_BOOL_TRUE}" ]]; then
        ez_print_log -l INFO -m "Remote Command Succeeded!"
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
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
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
    usage_string+=$(ez_build_usage -o "add" -a "--prompt" -d "The switch user's prompt, default = \"#${EZ_BASH_SPACE}\", for \"app\" user use \"\$${EZ_BASH_SPACE}\"")
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
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${sudo_pwd}" == "" ]]; then read -s -p "Password: " sudo_pwd; echo; fi
    if [[ "${prompt}" == "" ]]; then prompt="#${EZ_BASH_SPACE}"; fi
    if [[ "${hosts}" == "" ]]; then ez_print_log -l ERROR -m "Hostnames cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${cmd}" == "" ]]; then ez_print_log -l ERROR -m "Command cannot be empty"; ez_print_usage "${usage_string}"; return 1; fi
    if [[ "${timeout}" == "" ]]; then timeout=120; fi
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
        ez_ssh_sudo_cmd -l "${log_file_tmp}" -h "${host}" -u "${switch_user}" --cmd "${cmd}" --pwd "${sudo_pwd}" -of "${log_file}" --timeout "${timeout}" --prompt "${prompt}"
        local exit_code=${?}
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
        echo "Failure (${failure_count}): ${result_map["Failure"]}"
        echo "Success (${success_count}): ${result_map["Success"]}"
    fi
}
