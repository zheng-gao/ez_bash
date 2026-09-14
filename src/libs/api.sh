###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_API_DRY_RUN="False"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.api {
    if ez.function.unregistered; then
        ez.argument.set --short "-u" --long "--url" --info "The full url overrides domain, port, endpoint, params"  &&
        ez.argument.set --short "-a" --long "--auth" --info "Username:Password" &&
        ez.argument.set --short "-X" --long "--method" --default "GET" --choices "GET" "PUT" "POST" "PATCH" "DELETE" "OPTION" "HEAD" &&
        ez.argument.set --short "-D" --long "--domain" &&
        ez.argument.set --short "-P" --long "--port" &&
        ez.argument.set --short "-k" --long "--insecure" --type "Flag" --info "Ignore Cert" &&
        ez.argument.set --short "-v" --long "--version" --info "Endpoint version prefix" &&
        ez.argument.set --short "-e" --long "--endpoint" --info "Url after domain and port with no parameters" &&
        ez.argument.set --short "-E" --long "--ends-with-slash" --type "Flag" --info "Ensure the url ends with a slash" &&
        ez.argument.set --short "-p" --long "--params" --type "List" --info "HTTP parameters" &&
        ez.argument.set --short "-I" --long "--head" --type "Flag" --info "Show Headers Only" &&
        ez.argument.set --short "-H" --long "--headers" --type "List" --default "Accept: application/json" "Content-Type: application/json" --info "HTTP headers" &&
        ez.argument.set --short "-F" --long "--forms" --type "List" --info "Forms" &&
        ez.argument.set --short "-x" --long "--extra-headers" --type "List" --info "Extra HTTP Headers" &&
        ez.argument.set --short "-d" --long "--data" --info "PUT/POST payload" &&
        ez.argument.set --short "-T" --long "--upload-file" --info "File Path" &&
        ez.argument.set --short "-o" --long "--output" --info "Output Path" &&
        ez.argument.set --short "-V" --long "--verbose" --type "Flag" --info "Print request details (curl -v)" &&
        ez.argument.set --short "-t" --long "--dry-run" --type "Flag" --info "Print Command Only, No Execution" &&
        ez.argument.set --short "-r" --long "--return-type" --default "BodyOnly" --choices "BodyOnly" "CodeOnly" "BodyAndCode" --info "Print HTTP response body or code" || return 1
    fi; ez.function.help "${@}" || return 0
    local url && url="$(ez.argument.get --short "-u" --long "--url" --arguments "${@}")" &&
    local auth && auth="$(ez.argument.get --short "-a" --long "--auth" --arguments "${@}")" &&
    local method && method="$(ez.argument.get --short "-X" --long "--method" --arguments "${@}")" &&
    local domain && domain="$(ez.argument.get --short "-D" --long "--domain" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-P" --long "--port" --arguments "${@}")" &&
    local insecure && insecure="$(ez.argument.get --short "-k" --long "--insecure" --arguments "${@}")" &&
    local version && version="$(ez.argument.get --short "-v" --long "--version" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez.argument.get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local ends_with_slash && ends_with_slash="$(ez.argument.get --short "-E" --long "--ends-with-slash" --arguments "${@}")" &&
    local head && head="$(ez.argument.get --short "-I" --long "--head" --arguments "${@}")" &&
    local headers && ez.function.arguments.get_list "headers" "$(ez.argument.get --short "-H" --long "--headers" --arguments "${@}")" &&
    local forms && ez.function.arguments.get_list "forms" "$(ez.argument.get --short "-F" --long "--forms" --arguments "${@}")" &&
    local x_headers && ez.function.arguments.get_list "x_headers" "$(ez.argument.get --short "-x" --long "--extra-headers" --arguments "${@}")" &&
    local params && ez.function.arguments.get_list "params" "$(ez.argument.get --short "-p" --long "--params" --arguments "${@}")" &&
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local upload_file && upload_file="$(ez.argument.get --short "-T" --long "--upload-file" --arguments "${@}")" &&
    local output && output="$(ez.argument.get --short "-o" --long "--output" --arguments "${@}")" &&
    local verbose && verbose="$(ez.argument.get --short "-V" --long "--verbose" --arguments "${@}")" &&
    local dryrun && dryrun="$(ez.argument.get --short "-t" --long "--dry-run" --arguments "${@}")" &&
    local return_type && return_type="$(ez.argument.get --short "-r" --long "--return-type" --arguments "${@}")" || return 1
    local params_str=""; [[ -n "${params[*]}" ]] && params_str="?$(ez.join.not.none '&' "${params[@]}")"
    local headers_opt=() header; for header in "${headers[@]}" "${x_headers[@]}"; do headers_opt+=("-H" "\"${header}\""); done
    local forms_opt=() form; for form in "${forms[@]}"; do forms_opt+=("-F" "\"${form}\""); done
    local auth_op=(); [[ -n "${auth}" ]] && auth_op=("-u" "\"${auth}\"")
    if [[ "${ends_with_slash}" = "True" && "${endpoint:0-1}" != "/" ]]; then endpoint+="/"; fi
    if [[ -z "${url}" ]]; then [[ -n "${port}" ]] && domain="${domain}:${port}"; url="https://${domain}${version}${endpoint}${params_str}"; fi
    local curl_str="curl -sL ${auth_op[*]} ${headers_opt[*]} ${forms_opt[*]} \"${url}\""
    [[ "${method}" != "GET" ]] && curl_str+=" -X ${method}"
    [[ -n "${data}" ]] && curl_str+=" -d '${data}'"
    [[ -n "${upload_file}" ]] && curl_str+=" -T '${upload_file}'"
    [[ -n "${output}" ]] && curl_str+=" -o '${output}'"
    [[ "${head}" = "True" ]] && curl_str+=" -I"
    [[ "${insecure}" = "True" ]] && curl_str+=" -k"
    [[ "${verbose}" = "True" ]] && curl_str+=" -v"
    [[ "${return_type}" = "BodyAndCode" ]] && curl_str+=" -w \"%{http_code}\""
    [[ "${return_type}" = "CodeOnly" ]] && curl_str+=" -w \"%{http_code}\" -o \"/dev/null\""  # -w "%{stderr}%{http_code}" redirect http code to stderr
    if [[ "${dryrun}" = "True" || "${EZ_API_DRY_RUN}" = "True" ]]; then
        >&2 echo "${curl_str}"
    else
        bash -c "${curl_str}"  # eval "${curl_str}"
    fi
}

function ez.api.pagination {
    if ez.function.unregistered; then
        ez.argument.set --short "-u" --long "--url" --info "The full url overrides domain, port, endpoint, params"  &&
        ez.argument.set --short "-a" --long "--auth" --info "Username:Password" &&
        ez.argument.set --short "-D" --long "--domain" &&
        ez.argument.set --short "-P" --long "--port" &&
        ez.argument.set --short "-e" --long "--endpoint" --info "Url after domain and port with no parameters" &&
        ez.argument.set --short "-E" --long "--expected-code" --default 200 --info "HTTP Return Code on a Successful Request" && 
        ez.argument.set --short "-H" --long "--headers" --type "List" --default "Accept: application/json" --info "HTTP headers" &&
        ez.argument.set --short "-x" --long "--extra-headers" --type "List" --info "Extra HTTP Headers" &&
        ez.argument.set --short "-p" --long "--params" --type "List" --info "HTTP parameters" &&
        ez.argument.set --short "-l" --long "--limit" --required --default 30 --info "Page Size Limit" &&
        ez.argument.set --short "-lk" --long "--limit-key" --required --default "limit" --info "Param key of the page limit" &&
        ez.argument.set --short "-pk" --long "--page-key" --exclude "pagination" --info "Param key of the page id" &&
        ez.argument.set --short "-ok" --long "--offset-key" --exclude "pagination" --info "Param key of the offset" &&
        ez.argument.set --short "-df" --long "--data-filter" --default ".data" --info "JQ key selector of the data part" &&
        ez.argument.set --short "-nf" --long "--next-filter" --default ".pagination.links.next" --info "JQ key selector of the next page link" &&
        ez.argument.set --short "-tf" --long "--total-filter" --default ".pagination.total" --info "JQ key selector of the total items" &&
        ez.argument.set --short "-s" --long "--show-progress" --type "Flag" --info "Show Pagination Progress" || return 1
    fi; ez.function.help "${@}" || return 0
    local url && url="$(ez.argument.get --short "-u" --long "--url" --arguments "${@}")" &&
    local auth && auth="$(ez.argument.get --short "-a" --long "--auth" --arguments "${@}")" &&
    local domain && domain="$(ez.argument.get --short "-D" --long "--domain" --arguments "${@}")" &&
    local port && port="$(ez.argument.get --short "-P" --long "--port" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez.argument.get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local expected_code && expected_code="$(ez.argument.get --short "-E" --long "--expected-code" --arguments "${@}")" &&
    local headers && ez.function.arguments.get_list "headers" "$(ez.argument.get --short "-H" --long "--headers" --arguments "${@}")" &&
    local x_headers && ez.function.arguments.get_list "x_headers" "$(ez.argument.get --short "-x" --long "--extra-headers" --arguments "${@}")" &&
    local params && ez.function.arguments.get_list "params" "$(ez.argument.get --short "-p" --long "--params" --arguments "${@}")" &&
    local limit && limit="$(ez.argument.get --short "-l" --long "--limit" --arguments "${@}")" &&
    local limit_key && limit_key="$(ez.argument.get --short "-lk" --long "--limit-key" --arguments "${@}")" &&
    local page_key && page_key="$(ez.argument.get --short "-pk" --long "--page-key" --arguments "${@}")" &&
    local offset_key && offset_key="$(ez.argument.get --short "-ok" --long "--offset-key" --arguments "${@}")" &&
    local data_filter && data_filter="$(ez.argument.get --short "-df" --long "--data-filter" --arguments "${@}")" &&
    local next_filter && next_filter="$(ez.argument.get --short "-nf" --long "--next-filter" --arguments "${@}")" &&
    local total_filter && total_filter="$(ez.argument.get --short "-tf" --long "--total-filter" --arguments "${@}")" &&
    local show_progress && show_progress="$(ez.argument.get --short "-s" --long "--show-progress" --arguments "${@}")" || return 1
    local all_results="" result="" data="" size=0 offset=0 page=1 total=0 progress=0 progress_str="" progress_prefix="" next_url=""
    if [[ -n "${url}" ]]; then
        progress_prefix="${url}"
    else
        if [[ -n "${domain}" ]]; then progress_prefix+="domain: ${domain}"; fi
        if [[ -n "${endpoint}" ]]; then progress_prefix+=", endpoint: ${endpoint}"; fi
        if [[ -n "${params[@]}" ]]; then progress_prefix+=", params: ${params[@]}"; fi
    fi
    while true; do
        result="$(
            ez.api --url "${url}" --auth "${auth}" --domain "${domain}" --port "${port}" --endpoint "${endpoint}" --return-type "BodyAndCode" \
                --headers "${headers[@]}" --extra-headers "${x_headers[@]}" \
                --params "${limit_key}=${limit}" \
                    "$([[ -n "${page_key}" ]] && echo "${page_key}=${page}")" \
                    "$([[ -n "${offset_key}" ]] && echo "${offset_key}=${offset}")" \
                    "${params[@]}"
        )"
        # Extract the last line (the status code), everything except the last line (the body)
        local http_code body; http_code="$(tail -n1 <<< "${result}")"; body="$(sed '$ d' <<< "${result}")"
        if [[ "${expected_code}" != "${http_code}" ]]; then echo "${body}"; return 1; fi
        total="$(jq -r "${total_filter}" <<< "${body}")"
        next_url="$(jq -r "${next_filter}" <<< "${body}")"
        data="$(jq -c "${data_filter}" <<< "${body}")"
        size="$(jq "length" <<< "${data}")"
        if [[ "${data}" = "null" ]]; then data=""; else data="${data:1:-1}"; fi
        if [[ -n "${all_results}" ]]; then all_results+=","; fi; all_results+="${data}"
        if [[ "${show_progress}" = "${EZ_TRUE}" ]]; then
            ((progress+="${size}"))
            progress_str="${progress_prefix}, page: ${page}, offset: ${offset}, limit: ${limit}, size: ${size}, progress: ${progress}"
            if [[ "${total}" != "null" ]]; then progress_str+=", total: ${total}"; fi
            >&2 echo "${progress_str}"
        fi
        ((offset+="${size}")); ((page++))
        if [[ "${total}" != "null" && "${offset}" -ge "${total}" ]]; then break; fi
        if [[ "${next_url}" = "null" ]]; then break; else url="${next_url}"; fi
    done
    echo "[${all_results}]"
}


