#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_compare_version() {
    ez_set_argument --short "-o" --long "--operation" --choices "GreaterThan" "GreaterThanOrEqualTo" "EqualTo" "LessThanOrEqualTo" "LessThan" --required &&
    ez_set_argument --short "-d" --long "--delimiter" --default "." --required --info "Version Item Delimiter" &&
    ez_set_argument --short "-l" --long "--left-version" --required --info "The Left Version" &&
    ez_set_argument --short "-r" --long "--right-version" --required --info "The Right Version" &&
    ez_set_argument --short "-c" --long "--check-length" --type "Flag" --info "Do Not Compare Versions with Different Lengths" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local operation; operation="$(ez_get_argument --short "-o" --long "--operation" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local delimiter; delimiter="$(ez_get_argument --short "-d" --long "--delimiter" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local left_version; left_version="$(ez_get_argument --short "-l" --long "--left-version" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local right_version; right_version="$(ez_get_argument --short "-r" --long "--right-version" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local check_length; check_length="$(ez_get_argument --short '-c' --long "--check-length" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local left_version_list=(${left_version//${delimiter}/" "}); local left_length=${#left_version_list[@]}
    local right_version_list=(${right_version//${delimiter}/" "}); local right_length=${#right_version_list[@]}
    if [[ "${check_length}" = "${EZ_BASH_BOOL_TRUE}" ]] && [[ "${left_length}" -ne "${right_length}" ]]; then
    	ez_log_error "The length of \"${left_version}\" and \"${right_version}\" does not match"; return 1
    fi
    local state=0; local i=0; while [[ "${i}" -lt "${left_length}" ]] && [[ "${i}" -lt "${right_length}" ]]; do
        ((state = ${left_version_list[${i}]} - ${right_version_list[${i}]})); [[ "${state}" -ne 0 ]] && break; ((++i))
    done
    if [[ "${state}" -lt 0 ]]; then
        if [[ "${operation}" =~ "LessThan" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; return 0; else echo "${EZ_BASH_BOOL_FALSE}"; return 255; fi
    elif [[ "${state}" -gt 0 ]]; then
        if [[ "${operation}" =~ "GreaterThan" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; return 0; else echo "${EZ_BASH_BOOL_FALSE}"; return 255; fi
    elif [[ "${left_length}" -lt "${right_length}" ]]; then
        if [[ "${operation}" =~ "LessThan" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; return 0; else echo "${EZ_BASH_BOOL_FALSE}"; return 255; fi
    elif [[ "${left_length}" -gt "${right_length}" ]]; then
        if [[ "${operation}" =~ "GreaterThan" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; return 0; else echo "${EZ_BASH_BOOL_FALSE}"; return 255; fi
    else
        if [[ "${operation}" =~ "EqualTo" ]]; then echo "${EZ_BASH_BOOL_TRUE}"; return 0; else echo "${EZ_BASH_BOOL_FALSE}"; return 255; fi
    fi
}