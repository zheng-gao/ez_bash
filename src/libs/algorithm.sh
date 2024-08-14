###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez.sort {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--data" --type "List" --required &&
        ez.argument.set --short "-n" --long "--number" --type "Flag" &&
        ez.argument.set --short "-r" --long "--reverse" --type "Flag" || return 1
    fi; ez.function.help "${@}" || return 0
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local number && number="$(ez.argument.get --short "-n" --long "--number" --arguments "${@}")" &&
    local reverse && reverse="$(ez.argument.get --short "-r" --long "--reverse" --arguments "${@}")" || return 1
    local ez_sort_data_list; ez.function.arguments.get_list "ez_sort_data_list" "${data}"
    if [[ "${#ez_sort_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi; local item
    if ez.is_true "${number}" && ez.is_true "${reverse}"; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -n -r
    elif ez.is_true "${number}"; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -n
    elif ez.is_true "${reverse}"; then
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort -r
    else
        { for item in "${ez_sort_data_list[@]}"; do echo "${item}"; done } | sort
    fi
}