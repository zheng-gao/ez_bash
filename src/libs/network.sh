###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "netstat" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_netstat {
    local os=$(ez_os_name)
    if [[ "${os}" = "macos" ]]; then netstat -p "UDP" -p "TCP" -anv | grep -i "listen\|Local Address"
    elif [[ "${os}" = "linux" ]]; then netstat -tulpn | grep -i "listen\|Local Address"
    else ez_log_error "Unsupported ${os}" && return 2
    fi
}
