#!/usr/bin/env bash

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_function.sh"; then exit 1; fi

###################################################################################################
# --------------------------------------- Main Function ----------------------------------------- #
###################################################################################################
function ez_get_list() {
    local input="${1}"
    local item=""
    local length="${#input}"
    local last_index=0
    ((last_index=length-1))
    for ((k=0; k < "${length}"; ++k)); do
        local char="${input:k:1}"
        if [[ "${char}" == "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" ]]; then
            [[ ! -z "${item}" ]] && echo "${item}"
            item=""
        else
            item+="${char}"
        fi
        [[ "${k}" -eq "${last_index}" ]] && [[ ! -z "${item}" ]] && echo "${item}"
    done
}

function ez_test_core_function() {
    ez_set_argument --short "-n" --long "--name" --default "Tester" --info "Your Name" &&
    ez_set_argument -s "-g" --long "--gender" -d "Both Genders" --choices "Both Genders" "Male" "Female" --info "Your Gender" &&
    ez_set_argument -s "-p" -l "--pets" --type "List" -d "Chiwawa Dog" "Cat" "Beta Fish" -i "Pets List" &&
    ez_set_argument -s "-h" -l "--happy" -t "Flag" -i "Are you happy?" || return 1
    ez_ask_for_help "${@}" && ez_function_help && return
    local name; name="$(ez_get_argument --short '-n' --long '--name' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local gender; gender="$(ez_get_argument --short '-g' --long '--gender' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pets; pets="$(ez_get_argument --short '-p' --long '--pets' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local happy; happy="$(ez_get_argument --short '-h' --long "--happy" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Name = ${name}"
    echo "Gender = ${gender}"
    echo "Happy = ${happy}"
    echo "Pets = "; tr "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" "\n" <<< "${pets}"
    echo "Pets = "; ez_get_list "${pets}"
}

echo "[Test 1]"
ez_test_core_function --help
echo
echo "[Test 2]"
ez_test_core_function --name "EZ-QA" -g "Female" --happy --pets "Guinea Pig" "Bird"
echo
echo "[Test 3]"
ez_test_core_function --happy
echo
echo "[Test 4]"
ez_test_core_function --gender "Both Genders" --happy
echo
