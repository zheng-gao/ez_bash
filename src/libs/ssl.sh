###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "openssl" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_show_cert {
    if ez_function_unregistered; then
        ez_arg_set --short "-h" --long "--hostname" --required --info "FQDN" &&
        ez_arg_set --short "-p" --long "--port" --required --default "443" --info "Port Number" ||
        return 1
    fi
    ez_function_usage "${@}" && return
    local hostname && hostname="$(ez_arg_get --short "-h" --long "--hostname" --arguments "${@}")" &&
    local port && port="$(ez_arg_get --short "-p" --long "--port" --arguments "${@}")" || return 1
    echo | openssl "s_client" -connect "${hostname}:${port}" -showcerts | openssl "x509" -noout -text
}
