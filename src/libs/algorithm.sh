###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "sort" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_sort {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--data" --type "List" --required &&
        ez_arg_set --short "-n" --long "--number" --type "Flag" &&
        ez_arg_set --short "-r" --long "--reverse" --type "Flag" || return 1
    fi
    ez_function_usage "${@}" && return
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local number && number="$(ez_arg_get --short "-n" --long "--number" --arguments "${@}")" &&
    local reverse && reverse="$(ez_arg_get --short "-r" --long "--reverse" --arguments "${@}")" || return 1
    local ez_sort_data_list; ez_function_get_list "ez_sort_data_list" "${data}"
    if [[ "${#ez_sort_data_list[@]}" -eq 0 ]]; then ez_log_error "No data found"; return 1; fi
    local item
    if [[ "${number}" = "${EZ_BOOL_TRUE}" ]] && [[ "${reverse}" = "${EZ_BOOL_TRUE}" ]]; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -n -r
    elif [[ "${number}" = "${EZ_BOOL_TRUE}" ]]; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -n
    elif [[ "${reverse}" = "${EZ_BOOL_TRUE}" ]]; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -r
    else
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort
    fi
}