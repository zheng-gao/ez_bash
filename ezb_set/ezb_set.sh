function ezb_set_operation() {
    if ! ezb_function_exist; then
        local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
        ezb_set_arg --short "-o" --long "--operation" --required --default "Intersection" --choices "${valid_operation[@]}" &&
        ezb_set_arg --short "-l" --long "--left" --type "List" --info "Left Set: Item_l1 Item_l2 ..." &&
        ezb_set_arg --short "-r" --long "--right" --type "List" --info "Right Set: Item_r1 Item_r2 ..." || return 1
    fi
    ezb_function_usage "${@}" && return
    local operation; operation="$(ezb_get_arg --short "-o" --long "--operation" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local left; left="$(ezb_get_arg --short "-l" --long "--left" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local right; right="$(ezb_get_arg --short "-r" --long "--right" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    declare -A left_set; declare -A right_set; local item=""
    for item in $(ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${left}"); do left_set["${item}"]=0; done
    for item in $(ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${right}"); do right_set["${item}"]=0; done
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

function ezb_set_contains() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-l" --long "--large" --type "List" --info "Large Set: Item_l1 Item_l2 ..." &&
        ezb_set_arg --short "-s" --long "--small" --type "List" --info "Small Set: Item_r1 Item_r2 ..." &&
        ezb_set_arg --short "-v" --long "--verbose" --type "Flag" --info "Print Result" || return 1
    fi
    ezb_function_usage "${@}" && return
    local large; large="$(ezb_get_arg --short "-l" --long "--large" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local small; small="$(ezb_get_arg --short "-s" --long "--small" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local verbose; verbose="$(ezb_get_arg --short "-v" --long "--verbose" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    declare -A large_set; declare -A small_set; local item=""
    for item in $(ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${large}"); do large_set["${item}"]=0; done
    for item in $(ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${small}"); do small_set["${item}"]=0; done
    for item in "${!small_set[@]}"; do
        if [[ ! ${large_set["${item}"]+_} ]]; then
            [[ "${verbose}" = "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_FALSE}"; return 1
        fi
    done
    [[ "${verbose}" == "${EZB_BOOL_TRUE}" ]] && echo "${EZB_BOOL_TRUE}"; return 0
}
