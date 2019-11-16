function ezb_get_diff_between_two_sets() {
    local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
    local valid_operation_string=$(ezb_join ', ' "${valid_operation[@]}")
    local usage_string=$(ezb_build_usage -o "init" -d "Get the differences between two sets")
    usage_string+=$(ezb_build_usage -o "add" -a "-o|--operation" -d "[${valid_operation_string}], default = ${valid_operation[0]}")
    usage_string+=$(ezb_build_usage -o "add" -a "-l|--left" -d "Left Set: Item_l1 Item_l2 ...")
    usage_string+=$(ezb_build_usage -o "add" -a "-r|--right" -d "Right Set: Item_r1 Item_r2 ...")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local operation=${valid_operation[0]}
    declare -A left_set
    declare -A right_set
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-o" | "--operation") shift; operation=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-l" | "--left") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-o" ]] || [[ "${1-}" == "--operation" ]]; then break; fi
                    if [[ "${1-}" == "-r" ]] || [[ "${1-}" == "--right" ]]; then break; fi
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--left" ]]; then break; fi
                    left_set["${1-}"]="${EZB_BOOL_TRUE}"; shift
                done ;;
            "-r" | "--right") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-o" ]] || [[ "${1-}" == "--operation" ]]; then break; fi
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--left" ]]; then break; fi
                    if [[ "${1-}" == "-r" ]] || [[ "${1-}" == "--right" ]]; then break; fi
                    right_set["${1-}"]="${EZB_BOOL_TRUE}"; shift
                done ;;
            *) ezb_log_error "Unknown argument \"$1\""; ezb_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    local item=""
    if [[ "${operation}" == "Intersection" ]]; then
        for item in "${!left_set[@]}"; do
            if [ ${right_set["${item}"]+_} ]; then echo "${item}"; fi
        done
    elif [[ "${operation}" == "Union" ]]; then
        declare -A union_set
        for item in "${!left_set[@]}"; do union_set["${item}"]="${EZB_BOOL_TRUE}"; done
        for item in "${!right_set[@]}"; do union_set["${item}"]="${EZB_BOOL_TRUE}"; done
        for item in "${!union_set[@]}"; do echo ${item}; done
    elif [[ "${operation}" == "LeftOnly" ]]; then
        for item in "${!left_set[@]}"; do
            if [ ! ${right_set["${item}"]+_} ]; then echo "${item}"; fi
        done
    elif [[ "${operation}" == "RightOnly" ]]; then
        for item in "${!right_set[@]}"; do
            if [ ! ${left_set["${item}"]+_} ]; then echo "${item}"; fi
        done
    else
        ezb_log_error "Invalid Operation \"${operation}\""; ezb_print_usage "${usage_string}"; return 1
    fi
}


function ezb_is_subset() {
    local valid_operation=("A-IN-B" "B-IN-A")
    local valid_operation_string=$(ezb_join ', ' "${valid_operation[@]}")
    local usage_string=$(ezb_build_usage -o "init" -d "Check if a set is the subset of another set, Null is a subset of All sets")
    usage_string+=$(ezb_build_usage -o "add" -a "-o|--operation" -d "[${valid_operation_string}], default = ${valid_operation[0]}")
    usage_string+=$(ezb_build_usage -o "add" -a "-a|--set-A" -d "Set A: Item_l1 Item_l2 ...")
    usage_string+=$(ezb_build_usage -o "add" -a "-b|--set-B" -d "Set B: Item_r1 Item_r2 ...")
    usage_string+=$(ezb_build_usage -o "add" -a "-s|--silent" -d "Hide the output")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ezb_print_usage "${usage_string}"; return 1; fi
    local operation=${valid_operation[0]}
    local silent="${EZB_BOOL_FALSE}"
    declare -A set_a
    declare -A set_b
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-s" | "--silent") shift; silent="${EZB_BOOL_TRUE}" ;;
            "-o" | "--operation") shift; operation=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-a" | "--set-A") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-o" ]] || [[ "${1-}" == "--operation" ]]; then break; fi
                    if [[ "${1-}" == "-b" ]] || [[ "${1-}" == "--set-B" ]]; then break; fi
                    if [[ "${1-}" == "-a" ]] || [[ "${1-}" == "--set-A" ]]; then break; fi
                    if [[ "${1-}" == "-s" ]] || [[ "${1-}" == "--silent" ]]; then break; fi
                    set_a["${1-}"]="${EZB_BOOL_TRUE}"; shift
                done ;;
            "-b" | "--set-B") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-o" ]] || [[ "${1-}" == "--operation" ]]; then break; fi
                    if [[ "${1-}" == "-a" ]] || [[ "${1-}" == "--set-A" ]]; then break; fi
                    if [[ "${1-}" == "-b" ]] || [[ "${1-}" == "--set-B" ]]; then break; fi
                    if [[ "${1-}" == "-s" ]] || [[ "${1-}" == "--silent" ]]; then break; fi
                    set_b["${1-}"]="${EZB_BOOL_TRUE}"; shift
                done ;;
            *) ezb_log_error "Unknown argument \"$1\""; ezb_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${operation}" == "A-IN-B" ]]; then
        for item in "${!set_a[@]}"; do
            if [ ! ${set_b["${item}"]+_} ]; then
                if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
                return 1
            fi
        done
        if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
        return 0
    elif [[ "${operation}" == "B-IN-A" ]]; then
        for item in "${!set_b[@]}"; do
            if [ ! ${set_a["${item}"]+_} ]; then
                if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then echo "${EZB_BOOL_FALSE}"; fi
                return 1
            fi
        done
        if [[ "${silent}" == "${EZB_BOOL_FALSE}" ]]; then echo "${EZB_BOOL_TRUE}"; fi
        return 0
    else
        ezb_log_error "Invalid Operation \"${operation}\""; ezb_print_usage "${usage_string}"; return 1
    fi
}
