function ez.collections.set.operation {
    if ez.function.unregistered; then
        local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
        ez.argument.set --short "-o" --long "--operation" --required --default "Intersection" --choices "${valid_operation[@]}" &&
        ez.argument.set --short "-l" --long "--left" --type "List" --info "Left Set: Item_l1 Item_l2 ..." &&
        ez.argument.set --short "-L" --long "--left-from-file" --info "File Path" &&
        ez.argument.set --short "-r" --long "--right" --type "List" --info "Right Set: Item_r1 Item_r2 ..." &&
        ez.argument.set --short "-R" --long "--right-from-file" --info "File Path"
        ez.argument.set --short "-s" --long "--summary" --type "Flag" --info "Show summary at the end" || return 1
    fi; ez.function.help "${@}" || return 0
    local operation && operation="$(ez.argument.get --short "-o" --long "--operation" --arguments "${@}")" &&
    local left && ez.function.arguments.get_list "left" "$(ez.argument.get --short "-l" --long "--left" --arguments "${@}")" &&
    local right && ez.function.arguments.get_list "right" "$(ez.argument.get --short "-r" --long "--right" --arguments "${@}")" &&
    local left_path && left_path="$(ez.argument.get --short "-L" --long "--left-from-file" --arguments "${@}")" &&
    local right_path && right_path="$(ez.argument.get --short "-R" --long "--right-from-file" --arguments "${@}")" &&
    local summary && summary="$(ez.argument.get --short "-s" --long "--summary" --arguments "${@}")" || return 1
    declare -A left_set
    declare -A right_set
    declare -A result_set
    local item
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
        for item in "${!left_set[@]}"; do [[ ${right_set["${item}"]+_} ]] && result_set["${item}"]=0; done
    elif [[ "${operation}" = "Union" ]]; then
        for item in "${!left_set[@]}"; do result_set["${item}"]=0; done
        for item in "${!right_set[@]}"; do result_set["${item}"]=0; done
    elif [[ "${operation}" = "LeftOnly" ]]; then
        for item in "${!left_set[@]}"; do [[ ! ${right_set["${item}"]+_} ]] && result_set["${item}"]=0; done
    elif [[ "${operation}" = "RightOnly" ]]; then
        for item in "${!right_set[@]}"; do [[ ! ${left_set["${item}"]+_} ]] && result_set["${item}"]=0; done
    fi
    { for item in "${!result_set[@]}"; do echo "${item}"; done; } | sort
    if ez.is_true "${summary}"; then
        echo "------ Summary ------"
        echo "  Left Size: ${#left_set[@]}"
        echo " Right Size: ${#right_set[@]}"
        echo "Result Size: ${#result_set[@]}"
    fi
}

function ez.collections.set.contains {
    if ez.function.unregistered; then
        ez.argument.set --short "-sp" --long "--superset" --type "List" --info "Superset: Item_l1 Item_l2 ..." &&
        ez.argument.set --short "-sb" --long "--subset" --type "List" --info "Subset: Item_s1 Item_s2 ..." &&
        ez.argument.set --short "-v" --long "--verbose" --type "Flag" --info "Print Result" || return 1
    fi; ez.function.help "${@}" || return 0
    local superset && ez.function.arguments.get_list "superset" "$(ez.argument.get --short "-sp" --long "--superset" --arguments "${@}")" &&
    local subset && ez.function.arguments.get_list "subset" "$(ez.argument.get --short "-sb" --long "--subset" --arguments "${@}")" &&
    local verbose && verbose="$(ez.argument.get --short "-v" --long "--verbose" --arguments "${@}")" || return 1
    declare -A sp_set; declare -A sb_set; local item
    for item in "${superset[@]}"; do sp_set["${item}"]=0; done
    for item in "${subset[@]}"; do sb_set["${item}"]=0; done
    for item in "${!sb_set[@]}"; do
        if [[ ! ${sp_set["${item}"]+_} ]]; then
            ez.is_true "${verbose}" && echo "${EZ_FALSE}"; return 1
        fi
    done
    ez.is_true "${verbose}" && echo "${EZ_TRUE}"; return 0
}
