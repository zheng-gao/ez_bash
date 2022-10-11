###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "nc" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_web() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-h" --long "--host" --required --default "localhost" --info "Hostname or IP" &&
        ezb_arg_set --short "-p" --long "--port" --required --default "5555" &&
        ezb_arg_set --short "-i" --long "--index" --info "Path to the index.html" &&
        ezb_arg_set --short "-b" --long "--background" --type "Flag" --info "Run server on background" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local host && host="$(ezb_arg_get --short "-h" --long "--host" --arguments "${@}")" &&
    local port && port="$(ezb_arg_get --short "-p" --long "--port" --arguments "${@}")" &&
    local index && index="$(ezb_arg_get --short "-i" --long "--index" --arguments "${@}")" &&
    local background && background="$(ezb_arg_get --short "-b" --long "--background" --arguments "${@}")" || return 1
    local os_name=$(ezb_os_name)
    local response_html='<!doctype html><html><body><h1>A webpage served with netcat</h1></body></html>'
    if [[ "${os_name}" == "linux" ]]; then
        if [[ -f "${index}" ]]; then
            if [[ "${background}" == "${EZB_BOOL_FALSE}" ]]; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}"
            else
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}" &
            fi
        else
        	if [[ "${background}" == "${EZB_BOOL_FALSE}" ]]; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'"
            else
            	nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'" &
            fi
        fi
    else
    	echo "Only works for linux" && return 1
    fi
}