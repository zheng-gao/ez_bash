###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "nc" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_web {
    if ez_function_unregistered; then
        ez_arg_set --short "-h" --long "--host" --required --default "localhost" --info "Hostname or IP" &&
        ez_arg_set --short "-p" --long "--port" --required --default "5555" &&
        ez_arg_set --short "-i" --long "--index" --info "Path to the index.html" &&
        ez_arg_set --short "-b" --long "--background" --type "Flag" --info "Run server on background" || return 1
    fi
    [[ -n "${@}" ]] && ez_function_usage "${@}" && return
    local host && host="$(ez_arg_get --short "-h" --long "--host" --arguments "${@}")" &&
    local port && port="$(ez_arg_get --short "-p" --long "--port" --arguments "${@}")" &&
    local index && index="$(ez_arg_get --short "-i" --long "--index" --arguments "${@}")" &&
    local background && background="$(ez_arg_get --short "-b" --long "--background" --arguments "${@}")" || return 1
    local os_name=$(ez_os_name)
    local response_html='<!doctype html><html><body><h1>A webpage served with netcat</h1></body></html>'
    if [[ "${os_name}" == "linux" ]]; then
        if [[ -f "${index}" ]]; then
            if [[ "${background}" == "${EZ_BOOL_FALSE}" ]]; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}"
            else
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}" &
            fi
        else
        	if [[ "${background}" == "${EZ_BOOL_FALSE}" ]]; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'"
            else
            	nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'" &
            fi
        fi
    else
    	echo "Only works for linux" && return 1
    fi
}