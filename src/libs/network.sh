###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "netstat" || return 1


###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.netstat {
    local exec_str="" grep_str="listen\|Local Address"
    if [[ "$(uname -s)" = "Darwin" ]]; then
        exec_str="netstat -anv -p UDP -p TCP | grep -i \"listen\|Local Address\""
    else  # Linux
        exec_str="netstat -tulpn | grep -i \"listen\|Local Address\""
    fi
    if [[ -n "${1}" ]]; then exec_str+=" | grep -i \"${1}\|Local Address\""; fi
    if [[ "${EZ_SUDO}" != "${EZ_FALSE}" ]]; then exec_str="sudo ${exec_str}"; fi
    eval "${exec_str}"
}

