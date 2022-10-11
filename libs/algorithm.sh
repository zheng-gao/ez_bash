###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "sort" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_sort() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--data" --type "List" --required &&
        ezb_arg_set --short "-n" --long "--number" --type "Flag" &&
        ezb_arg_set --short "-r" --long "--reverse" --type "Flag" || return 1
    fi
    ezb_function_usage "${@}" && return
    local data && data="$(ezb_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local number && number="$(ezb_arg_get --short "-n" --long "--number" --arguments "${@}")" &&
    local reverse && reverse="$(ezb_arg_get --short "-r" --long "--reverse" --arguments "${@}")" || return 1
    local ezb_sort_data_list; ezb_function_get_list "ezb_sort_data_list" "${data}"
    if [[ "${#ezb_sort_data_list[@]}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    local item
    if [[ "${number}" = "${EZB_BOOL_TRUE}" ]] && [[ "${reverse}" = "${EZB_BOOL_TRUE}" ]]; then
        { for item in "${ezb_sort_data_list[@]}"; do echo "${item}"; done } | sort -n -r
    elif [[ "${number}" = "${EZB_BOOL_TRUE}" ]]; then
        { for item in "${ezb_sort_data_list[@]}"; do echo "${item}"; done } | sort -n
    elif [[ "${reverse}" = "${EZB_BOOL_TRUE}" ]]; then
        { for item in "${ezb_sort_data_list[@]}"; do echo "${item}"; done } | sort -r
    else
        { for item in "${ezb_sort_data_list[@]}"; do echo "${item}"; done } | sort
    fi
}