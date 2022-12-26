function ezb_set_operation {
    if ezb_function_unregistered; then
        local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
        ezb_arg_set --short "-o" --long "--operation" --required --default "Intersection" --choices "${valid_operation[@]}" &&
        ezb_arg_set --short "-l" --long "--left" --type "List" --info "Left Set: Item_l1 Item_l2 ..." &&
        ezb_arg_set --short "-r" --long "--right" --type "List" --info "Right Set: Item_r1 Item_r2 ..." || return 1
    fi
    ezb_function_usage "${@}" && return
    local operation && operation="$(ezb_arg_get --short "-o" --long "--operation" --arguments "${@}")" &&
    local left && ezb_function_get_list "left" "$(ezb_arg_get --short "-l" --long "--left" --arguments "${@}")" &&
    local right && ezb_function_get_list "right" "$(ezb_arg_get --short "-r" --long "--right" --arguments "${@}")" || return 1
    declare -A left_set; declare -A right_set; local item
    for item in "${left[@]}"; do left_set["${item}"]=0; done
    for item in "${right[@]}"; do right_set["${item}"]=0; done
    if [[ "${operation}" = "Intersection" ]]; then
        for item in "${!left_set[@]}"; do [[ ${right_set["${item}"]+_} ]] && echo "${item}"; done
    elif [[ "${operation}" = "Union" ]]; then
        declare -A union_set
        for item in "${!left_set[@]}"; do union_set["${item}"]=0; done
        for item in "${!right_set[@]}"; do union_set["${item}"]=0; done
        for item in "${!union_set[@]}"; do echo "${item}"; done
    elif [[ "${operation}" = "LeftOnly" ]]; then
        for item in "${!left_set[@]}"; do [[ ! ${right_set["${item}"]+_} ]] && echo "${item}"; done
    elif [[ "${operation}" = "RightOnly" ]]; then
        for item in "${!right_set[@]}"; do [[ ! ${left_set["${item}"]+_} ]] && echo "${item}"; done
    fi
}

function ezb_set_contains {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-sp" --long "--superset" --type "List" --info "Superset: Item_l1 Item_l2 ..." &&
        ezb_arg_set --short "-sb" --long "--subset" --type "List" --info "Subset: Item_s1 Item_s2 ..." &&
        ezb_arg_set --short "-v" --long "--verbose" --type "Flag" --info "Print Result" || return 1
    fi
    ezb_function_usage "${@}" && return
    local superset && ezb_function_get_list "superset" "$(ezb_arg_get --short "-sp" --long "--superset" --arguments "${@}")" &&
    local subset && ezb_function_get_list "subset" "$(ezb_arg_get --short "-sb" --long "--subset" --arguments "${@}")" &&
    local verbose && verbose="$(ezb_arg_get --short "-v" --long "--verbose" --arguments "${@}")" || return 1
    declare -A sp_set; declare -A sb_set; local item
    for item in "${superset[@]}"; do sp_set["${item}"]=0; done
    for item in "${subset[@]}"; do sb_set["${item}"]=0; done
    for item in "${!sb_set[@]}"; do
        if [[ ! ${sp_set["${item}"]+_} ]]; then
            [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_FALSE}"; return 1
        fi
    done
    [[ "${verbose}" == "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_TRUE}"; return 0
}
