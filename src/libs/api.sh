function ez.api {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-u" --long "--url" --info "The full url overrides domain, port, endpoint, params"  &&
        ez.argument.set --short "-D" --long "--domain" &&
        ez.argument.set --short "-P" --long "--port" &&
        ez.argument.set --short "-k" --long "--insecure" --type "Flag" --info "Ignore Cert" &&
        ez.argument.set --short "-e" --long "--endpoint" --info "Url after domain and port with no parameters" &&
        ez.argument.set --short "-p" --long "--params" --type "List" --info "HTTP parameters" &&
        ez.argument.set --short "-X" --long "--method" --default "GET" --choices "GET" "PUT" "POST" "PATCH" "DELETE" "OPTION" "HEAD" &&
        ez.argument.set --short "-a" --long "--auth" --info "Username:Password" &&
        ez.argument.set --short "-I" --long "--head" --type "Flag" --info "Show Headers Only" &&
        ez.argument.set --short "-H" --long "--headers" --type "List" --default "Accept: application/json" "Content-Type: application/json" --info "HTTP headers" &&
        ez.argument.set --short "-x" --long "--extra-headers" --type "List" --info "Extra HTTP Headers" &&
        ez.argument.set --short "-d" --long "--data" --info "PUT/POST payload" &&
        ez.argument.set --short "-T" --long "--upload-file" --info "File Path" &&
        ez.argument.set --short "-o" --long "--output" --info "Output Path" &&
        ez.argument.set --short "-v" --long "--verbose" --type "Flag" --info "Print request details (curl -v)" &&
        ez.argument.set --short "-t" --long "--dry-run" --type "Flag" --info "Print Command Only, No Execution" || return 1
    fi; ez.function.help "${@}" && return
    local url && url="$(ez.argument.get --short "-u" --long "--url" --arguments "${@}")" &&
    local method && method="$(ez.argument.get --short "-X" --long "--method" --arguments "${@}")" &&
    local auth && auth="$(ez.argument.get --short "-a" --long "--auth" --arguments "${@}")" &&
    local domain && domain="$(ez.argument.get --short "-D" --long "--domain" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-P" --long "--port" --arguments "${@}")" &&
    local insecure && insecure="$(ez.argument.get --short "-k" --long "--insecure" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez.argument.get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local head && head="$(ez.argument.get --short "-I" --long "--head" --arguments "${@}")" &&
    local headers && ez.function.arguments.get_list "headers" "$(ez.argument.get --short "-H" --long "--headers" --arguments "${@}")" &&
    local x_headers && ez.function.arguments.get_list "x_headers" "$(ez.argument.get --short "-x" --long "--extra-headers" --arguments "${@}")" &&
    local params && ez.function.arguments.get_list "params" "$(ez.argument.get --short "-p" --long "--params" --arguments "${@}")" &&
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local upload_file && upload_file="$(ez.argument.get --short "-T" --long "--upload-file" --arguments "${@}")" &&
    local output && output="$(ez.argument.get --short "-o" --long "--output" --arguments "${@}")" &&
    local verbose && verbose="$(ez.argument.get --short "-v" --long "--verbose" --arguments "${@}")" &&
    local dryrun && dryrun="$(ez.argument.get --short "-t" --long "--dry-run" --arguments "${@}")" || return 1
    local params_str=""; [[ -n "${params[@]}" ]] && params_str="?$(ez.string.join '&' ${params[@]})"
    local headers_opt=() header; for header in "${headers[@]}" "${x_headers[@]}"; do headers_opt+=("-H" "\"${header}\""); done
    local auth_op=(); [[ -n "${auth}" ]] && auth_op=("-u" "\"${auth}\"")
    if [[ -z "${url}" ]]; then [[ -n "${port}" ]] && domain="${domain}:${port}"; url="https://${domain}${endpoint}${params_str}"; fi
    local curl_str="curl -sL ${auth_op[@]} ${headers_opt[@]} \"${url}\""
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