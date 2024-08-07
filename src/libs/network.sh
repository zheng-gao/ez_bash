###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "netstat" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.netstat {
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
