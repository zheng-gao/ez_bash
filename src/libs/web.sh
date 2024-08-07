###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "nc" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_web {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-h" --long "--host" --required --default "localhost" --info "Hostname or IP" &&
        ez.argument.set --short "-p" --long "--port" --required --default "5555" &&
        ez.argument.set --short "-i" --long "--index" --info "Path to the index.html" &&
        ez.argument.set --short "-b" --long "--background" --type "Flag" --info "Run server on background" || return 1
    fi
    [[ -n "${@}" ]] && ez.function.help "${@}" && return
    local host && host="$(ez.argument.get --short "-h" --long "--host" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-p" --long "--port" --arguments "${@}")" &&
    local index && index="$(ez.argument.get --short "-i" --long "--index" --arguments "${@}")" &&
    local background && background="$(ez.argument.get --short "-b" --long "--background" --arguments "${@}")" || return 1
    local response_html='<!doctype html><html><body><h1>A webpage served with netcat</h1></body></html>'
    if [[ "$(uname -s)" = "Linux" ]]; then
        if [[ -f "${index}" ]]; then
            if ez_is_false "${background}"; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}"
            else
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; cat ${index}" &
            fi
        else
        	if ez_is_false "${background}"; then
                nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'"
            else
            	nc -vkl "${host}" "${port}" -c "echo -e 'HTTP/1.1 200 OK\r\n'; echo '${response_html}'" &
            fi
        fi
    else
    	echo "Only works for linux" && return 1
    fi
}