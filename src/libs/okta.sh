###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "curl" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_okta_pagination {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-d" --long "--domain" --required --info "Domain Name" &&
        ez.argument.set --short "-e" --long "--endpoint" --required --info "API Endpoint" &&
        ez.argument.set --short "-t" --long "--token" --default "${OKTA_API_TOKEN}" --required --info "API Token" &&
        ez.argument.set --short "-l" --long "--limit" --default "100" --required --info "Page Limit" &&
        ez.argument.set --short "-m" --long "--max-pages" --default "10" --required --info "Max Number of Pages" || return 1
    fi
    ez.function.help "${@}" && return
    local domain && domain="$(ez.argument.get --short "-d" --long "--domain" --arguments "${@}")" &&
    local endpoint && endpoint="$(ez.argument.get --short "-e" --long "--endpoint" --arguments "${@}")" &&
    local token && token="$(ez.argument.get --short "-t" --long "--token" --arguments "${@}")" &&
    local limit && limit="$(ez.argument.get --short "-l" --long "--limit" --arguments "${@}")" &&
    local max_pages && max_pages="$(ez.argument.get --short "-m" --long "--max-pages" --arguments "${@}")" || return 1
    local page=1; max_pages="$(echo ${max_pages} | bc)"  # convert to int
    local url="https://${domain}/api/v1/${endpoint}?limit=${limit}"
    local result="" page_result="" next_link=""
    while [[ "${page}" -le "${max_pages}" ]] && [[ -n "${url}" ]]; do
        page_result=$(curl -sH "Authorization: SSWS ${token}" "${url}")
        next_link=$(curl -sIH "Authorization: SSWS ${token}" "${url}" | grep "link: " | grep "rel=\"next\"")
        url=$(echo "${next_link}" | cut -d "<" -f 2 | cut -d ">" -f 1)
        [[ -z "${result}" ]] && result="${page_result:1:-1}" || result+=",${page_result:1:-1}"
        ((++page))
    done
    echo "[${result}]" | jq
}