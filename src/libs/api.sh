function ez_api {
    if ez_function_unregistered; then
        ez_arg_set --short "-X" --long "--method" --required --default "GET" --choices "GET" "PUT" "POST" &&
        ez_arg_set --short "-a" --long "--auth" --info "Username:Password" &&
        ez_arg_set --short "-D" --long "--domain" --required  &&
        ez_arg_set --short "-P" --long "--port" &&
        ez_arg_set --short "-e" --long "--endpoint" --required --info "Url after domain and port with no parameters" &&
        ez_arg_set --short "-H" --long "--headers" --type "List" --default "Accept: application/json" "Content-Type: application/json" --required --info "HTTP headers" &&
        ez_arg_set --short "-x" --long "--extra-headers" --type "List" --info "Extra HTTP Headers" &&
        ez_arg_set --short "-p" --long "--params" --type "List" --info "HTTP parameters" &&
        ez_arg_set --short "-d" --long "--data" --info "PUT/POST payload" || return 1
    fi
    ez_function_usage "${@}" && return
    local method && method="$(ez_arg_get --short "-X" --long "--method" --arguments "${@}")" &&
    local auth && auth="$(ez_arg_get --short "-a" --long "--auth" --arguments "${@}")" &&
    local domain && domain="$(ez_arg_get --short "-D" --long "--domain" --arguments "${@}")" &&
    local port && port="$(ez_arg_get --short "-P" --long "--port" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez_arg_get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local headers && ez_function_get_list "headers" "$(ez_arg_get --short "-H" --long "--headers" --arguments "${@}")" &&
    local x_headers && ez_function_get_list "x_headers" "$(ez_arg_get --short "-x" --long "--extra-headers" --arguments "${@}")" &&
    local params && ez_function_get_list "params" "$(ez_arg_get --short "-p" --long "--params" --arguments "${@}")" &&
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" || return 1
    local params_str="?$(ez_join '&' ${params[@]})"
    local headers_opt=() header; for header in "${headers[@]}" "${x_headers[@]}"; do headers_opt+=("-H" "\"${header}\""); done
    local auth_op=(); [[ -n "${auth}" ]] && auth_op=("-u" "\"${auth}\"")
    [[ -n "${port}" ]] && domain="${domain}:${port}"
    local curl_str=""
    if [[ "${method}" = "GET" ]]; then
        curl_str="curl -s ${auth_op[@]} ${headers_opt[@]} https://${domain}${endpoint}${params_str}"
    else
        curl_str="curl -s ${auth_op[@]} ${headers_opt[@]} -X ${method} https://${domain}${endpoint}${params_str} -d '${data}'"
    fi
    bash -c "${curl_str}"  # eval "${curl_str}"
}