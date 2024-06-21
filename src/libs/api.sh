function ez_api {
    if ez_function_unregistered; then
        ez_arg_set --short "-u" --long "--url" --info "The full url overrides domain, port, endpoint, params"  &&
        ez_arg_set --short "-D" --long "--domain" &&
        ez_arg_set --short "-P" --long "--port" &&
        ez_arg_set --short "-k" --long "--insecure" --type "Flag" --info "Ignore Cert" &&
        ez_arg_set --short "-e" --long "--endpoint" --info "Url after domain and port with no parameters" &&
        ez_arg_set --short "-p" --long "--params" --type "List" --info "HTTP parameters" &&
        ez_arg_set --short "-X" --long "--method" --default "GET" --choices "GET" "PUT" "POST" "PATCH" &&
        ez_arg_set --short "-a" --long "--auth" --info "Username:Password" &&
        ez_arg_set --short "-I" --long "--head" --type "Flag" --info "Show Headers Only" &&
        ez_arg_set --short "-H" --long "--headers" --type "List" --default "Accept: application/json" "Content-Type: application/json" --info "HTTP headers" &&
        ez_arg_set --short "-x" --long "--extra-headers" --type "List" --info "Extra HTTP Headers" &&
        ez_arg_set --short "-d" --long "--data" --info "PUT/POST payload" &&
        ez_arg_set --short "-T" --long "--upload-file" --info "File Path" &&
        ez_arg_set --short "-o" --long "--output" --info "Output Path" &&
        ez_arg_set --short "-v" --long "--verbose" --type "Flag" --info "Print request details (curl -v)" &&
        ez_arg_set --short "-t" --long "--dry-run" --type "Flag" --info "Print Command Only, No Execution" || return 1
    fi
    ez_function_usage "${@}" && return
    local url && url="$(ez_arg_get --short "-u" --long "--url" --arguments "${@}")" &&
    local method && method="$(ez_arg_get --short "-X" --long "--method" --arguments "${@}")" &&
    local auth && auth="$(ez_arg_get --short "-a" --long "--auth" --arguments "${@}")" &&
    local domain && domain="$(ez_arg_get --short "-D" --long "--domain" --arguments "${@}")" &&
    local port && port="$(ez_arg_get --short "-P" --long "--port" --arguments "${@}")" &&
    local insecure && insecure="$(ez_arg_get --short "-k" --long "--insecure" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez_arg_get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local head && head="$(ez_arg_get --short "-I" --long "--head" --arguments "${@}")" &&
    local headers && ez_function_get_list "headers" "$(ez_arg_get --short "-H" --long "--headers" --arguments "${@}")" &&
    local x_headers && ez_function_get_list "x_headers" "$(ez_arg_get --short "-x" --long "--extra-headers" --arguments "${@}")" &&
    local params && ez_function_get_list "params" "$(ez_arg_get --short "-p" --long "--params" --arguments "${@}")" &&
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local upload_file && upload_file="$(ez_arg_get --short "-T" --long "--upload-file" --arguments "${@}")" &&
    local output && output="$(ez_arg_get --short "-o" --long "--output" --arguments "${@}")" &&
    local verbose && verbose="$(ez_arg_get --short "-v" --long "--verbose" --arguments "${@}")" &&
    local dryrun && dryrun="$(ez_arg_get --short "-t" --long "--dry-run" --arguments "${@}")" || return 1
    local params_str=""; [[ -n "${params[@]}" ]] && params_str="?$(ez_join '&' ${params[@]})"
    local headers_opt=() header; for header in "${headers[@]}" "${x_headers[@]}"; do headers_opt+=("-H" "\"${header}\""); done
    local auth_op=(); [[ -n "${auth}" ]] && auth_op=("-u" "\"${auth}\"")
    if [[ -z "${url}" ]]; then
        [[ -n "${port}" ]] && domain="${domain}:${port}"
        url="https://${domain}${endpoint}${params_str}"
    fi
    local curl_str="curl -s ${auth_op[@]} ${headers_opt[@]} \"${url}\""
    [[ "${method}" != "GET" ]] && curl_str+=" -X ${method}"
    [[ -n "${data}" ]] && curl_str+=" -d '${data}'"
    [[ -n "${upload_file}" ]] && curl_str+=" -T '${upload_file}'"
    [[ -n "${output}" ]] && curl_str+=" -o '${output}'"
    [[ "${head}" = "True" ]] && curl_str+=" -I"
    [[ "${insecure}" = "True" ]] && curl_str+=" -k"
    [[ "${verbose}" = "True" ]] && curl_str+=" -v"
    if [[ "${dryrun}" = "True" ]]; then
        >&2 echo "${curl_str}"
    else
        bash -c "${curl_str}"  # eval "${curl_str}"
    fi
}