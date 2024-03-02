###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "netstat" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_netstat {
    if [[ "$(uname -s)" = "Darwin" ]]; then
        if [[ "${1}" = "sudo" ]]; then
            sudo netstat -p "UDP" -p "TCP" -anv | grep -i "listen\|Local Address"
        else
            netstat -p "UDP" -p "TCP" -anv | grep -i "listen\|Local Address"
        fi
    else  # Linux
        if [[ "${1}" = "sudo" ]]; then
            sudo netstat -tulpn | grep -i "listen\|Local Address"
        else
            netstat -tulpn | grep -i "listen\|Local Address"
        fi
    fi
}
