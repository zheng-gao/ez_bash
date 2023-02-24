function ez_set_operation {
    if ez_function_unregistered; then
        local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
        ez_arg_set --short "-o" --long "--operation" --required --default "Intersection" --choices "${valid_operation[@]}" &&
        ez_arg_set --short "-l" --long "--left" --type "List" --info "Left Set: Item_l1 Item_l2 ..." &&
        ez_arg_set --short "-L" --long "--left-from-file" --info "File Path" &&
        ez_arg_set --short "-r" --long "--right" --type "List" --info "Right Set: Item_r1 Item_r2 ..." &&
        ez_arg_set --short "-R" --long "--right-from-file" --info "File Path" || return 1
    fi
    ez_function_usage "${@}" && return
    local operation && operation="$(ez_arg_get --short "-o" --long "--operation" --arguments "${@}")" &&
    local left && ez_function_get_list "left" "$(ez_arg_get --short "-l" --long "--left" --arguments "${@}")" &&
    local right && ez_function_get_list "right" "$(ez_arg_get --short "-r" --long "--right" --arguments "${@}")" &&
    local left_path && left_path="$(ez_arg_get --short "-L" --long "--left-from-file" --arguments "${@}")" &&
    local right_path && right_path="$(ez_arg_get --short "-R" --long "--right-from-file" --arguments "${@}")" || return 1
    declare -A left_set; declare -A right_set; local item
    if [[ -f "${left_path}" ]]; then
        for item in $(cat ${left_path}); do left_set["${item}"]=0; done
    else
        for item in "${left[@]}"; do left_set["${item}"]=0; done
    fi
    if [[ -f "${right_path}" ]]; then
        for item in $(cat ${right_path}); do right_set["${item}"]=0; done
    else
        for item in "${right[@]}"; do right_set["${item}"]=0; done
    fi
    if [[ "${operation}" = "Intersection" ]]; then
        { for item in "${!left_set[@]}"; do [[ ${right_set["${item}"]+_} ]] && echo "${item}"; done; } | sort
    elif [[ "${operation}" = "Union" ]]; then
        declare -A union_set
        for item in "${!left_set[@]}"; do union_set["${item}"]=0; done
        for item in "${!right_set[@]}"; do union_set["${item}"]=0; done
        { for item in "${!union_set[@]}"; do echo "${item}"; done; } | sort
    elif [[ "${operation}" = "LeftOnly" ]]; then
        { for item in "${!left_set[@]}"; do [[ ! ${right_set["${item}"]+_} ]] && echo "${item}"; done; } | sort
    elif [[ "${operation}" = "RightOnly" ]]; then
        { for item in "${!right_set[@]}"; do [[ ! ${left_set["${item}"]+_} ]] && echo "${item}"; done; } | sort
    fi
}

function ez_set_contains {
    if ez_function_unregistered; then
        ez_arg_set --short "-sp" --long "--superset" --type "List" --info "Superset: Item_l1 Item_l2 ..." &&
        ez_arg_set --short "-sb" --long "--subset" --type "List" --info "Subset: Item_s1 Item_s2 ..." &&
        ez_arg_set --short "-v" --long "--verbose" --type "Flag" --info "Print Result" || return 1
    fi
    ez_function_usage "${@}" && return
    local superset && ez_function_get_list "superset" "$(ez_arg_get --short "-sp" --long "--superset" --arguments "${@}")" &&
    local subset && ez_function_get_list "subset" "$(ez_arg_get --short "-sb" --long "--subset" --arguments "${@}")" &&
    local verbose && verbose="$(ez_arg_get --short "-v" --long "--verbose" --arguments "${@}")" || return 1
    declare -A sp_set; declare -A sb_set; local item
    for item in "${superset[@]}"; do sp_set["${item}"]=0; done
    for item in "${subset[@]}"; do sb_set["${item}"]=0; done
    for item in "${!sb_set[@]}"; do
        if [[ ! ${sp_set["${item}"]+_} ]]; then
            ez_is_true "${verbose}" && echo "${EZ_FALSE}"; return 1
        fi
    done
    ez_is_true "${verbose}" && echo "${EZ_TRUE}"; return 0
}
