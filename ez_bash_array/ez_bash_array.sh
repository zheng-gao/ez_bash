#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_split_string_into_array() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_split_string_into_array" -d "Split string by delimiter")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--delimiter" -d "Given delimiter, default = \",\"")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--string" -d "Given string")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local delimiter=","
    local input_string=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--delimiter") shift; delimiter=${1-} ;;
            "-s" | "--string") shift; input_string=${1-} ;;
            *) ez_print_log -l ERROR -m "Unknown argument \"$1\""; ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    if ! ez_nonempty_check -n "-d|--delimiter" -v "${delimiter}" -o "${usage_string}"; then return 1; fi
    if ! ez_nonempty_check -n "-s|--string" -v "${input_string}" -o "${usage_string}"; then return 1; fi
    echo "${input_string}" | column -t -s "${delimiter}"
}

function ez_print_array_with_delimiter() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_array_with_delimiter" -d "Print array with delimiter")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--delimiter" -d "Given Delimiter")
    usage_string+=$(ez_build_usage -o "add" -a "-a|--array" -d "Given Array Item_1 Item_2 ...")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local delimiter=""
    local array=()
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-d" | "--delimiter") shift; delimiter=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-a" | "--array") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-d" ]] || [[ "${1-}" == "--delimiter" ]]; then break; fi
                    array+=("${1-}"); shift
                done ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    local output_string=""
    if [[ "${#array[@]}" > 0 ]]; then
        output_string="${array[0]}"
        for ((index=1; index < "${#array[@]}"; ++index)); do
            output_string+="${delimiter}${array[${index}]}"
        done
    fi
    echo "${output_string}"
}

function ez_check_item_in_array() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_check_item_in_array" -d "Check if an item is in an array")
    usage_string+=$(ez_build_usage -o "add" -a "-i|--item" -d "Given Item")
    usage_string+=$(ez_build_usage -o "add" -a "-a|--array" -d "Given Array Item_1 Item_2 ...")
    usage_string+=$(ez_build_usage -o "add" -a "-s|--silent" -d "Hide the output")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local item=""
    local array=()
    local silent="${EZ_BASH_BOOL_FALSE}"
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-i" | "--item") shift; item=${1-}; if [[ ! -z "${1-}" ]]; then shift; fi ;;
            "-s" | "--silent") shift; silent="${EZ_BASH_BOOL_TRUE}" ;;
            "-a" | "--array") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-i" ]] || [[ "${1-}" == "--item" ]]; then break; fi
                    if [[ "${1-}" == "-s" ]] || [[ "${1-}" == "--silent" ]]; then break; fi
                    array+=("${1-}"); shift
                done ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    for item_x in "${array[@]}"; do
        if [[ "${item}" == "${item_x}" ]]; then
            if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; fi
            return 0
        fi
    done
    if [[ "${silent}" == "${EZ_BASH_BOOL_FALSE}" ]]; then echo "${EZ_BASH_BOOL_FALSE}"; fi
    return 1
}

function ez_get_diff_between_two_sets() {
    local valid_operation=("Intersection" "Union" "LeftOnly" "RightOnly")
    local valid_operation_string=$(ez_print_array_with_delimiter -d ", " -a "${valid_operation[@]}")
    local usage_string=$(ez_build_usage -o "init" -a "ez_get_diff_between_two_arrays" -d "Get the differences between two sets")
    usage_string+=$(ez_build_usage -o "add" -a "-o|--operation" -d "[${valid_operation_string}], default = ${valid_operation[0]}")
    usage_string+=$(ez_build_usage -o "add" -a "-l|--left" -d "Left Set: Item_l1 Item_l2 ...")
    usage_string+=$(ez_build_usage -o "add" -a "-r|--right" -d "Right Set: Item_r1 Item_r2 ...")
    if [[ "${1}" == "" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
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
                    left_set["${1-}"]="${EZ_BASH_BOOL_TRUE}"; shift
                done ;;
            "-r" | "--right") shift
                while [[ ! -z "${1-}" ]]; do
                    if [[ "${1-}" == "-o" ]] || [[ "${1-}" == "--operation" ]]; then break; fi
                    if [[ "${1-}" == "-l" ]] || [[ "${1-}" == "--left" ]]; then break; fi
                    right_set["${1-}"]="${EZ_BASH_BOOL_TRUE}"; shift
                done ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
    done
    if [[ "${operation}" == "Intersection" ]]; then
        for item in "${!left_set[@]}"; do
            if [ ${right_set["${item}"]+_} ]; then echo "${item}"; fi
        done
    elif [[ "${operation}" == "Union" ]]; then
        declare -A union_set
        for item in "${!left_set[@]}"; do union_set["${item}"]="${EZ_BASH_BOOL_TRUE}"; done
        for item in "${!right_set[@]}"; do union_set["${item}"]="${EZ_BASH_BOOL_TRUE}"; done
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
        ez_print_log -l ERROR -m "Invalid Operation \"${operation}\""
        ez_print_usage "${usage_string}"; return 1
    fi
}

