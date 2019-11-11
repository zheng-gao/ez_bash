###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
[[ -z "${EZ_BASH_HOME}" ]] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1

if ! source "${EZ_BASH_HOME}/ezb_core/ezb_export_vars.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ezb_core/ezb_core_utils.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ezb_core/ezb_func_defs.sh"; then exit 1; fi

###################################################################################################
# --------------------------------------- Main Function ----------------------------------------- #
###################################################################################################
function ez_test_get_list() {
    local input="${1}"
    local item=""
    local length="${#input}"
    local last_index=0
    ((last_index=length-1))
    for ((k=0; k < "${length}"; ++k)); do
        local char="${input:k:1}"
        if [ "${char}" = "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" ]; then
            [ -n "${item}" ] && echo "${item}"
            item=""
        else
            item+="${char}"
        fi
        [ "${k}" -eq "${last_index}" ] && [ -n "${item}" ] && echo "${item}"
    done
}

function ez_test_core_function_1() {
    if ! ez_function_exist; then
        ez_set_argument -s "-t" --required -i "Your Title" &&
        ez_set_argument --short "-n" --long "--name" --default "Tester" --info "Your Name" &&
        ez_set_argument -s "-g" --long "--gender" -d "Both Genders" --choices "Both Genders" "Male" "Female" --info "Your Gender" &&
        ez_set_argument -s "-p" -l "--pets" --type "List" -d "Chiwawa Dog" "Cat" "Beta Fish" -i "Pets List" &&
        ez_set_argument -s "-h" -l "--happy" -t "Flag" || return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local title="$(ez_get_argument --short '-t' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local name="$(ez_get_argument --short '-n' --long '--name' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local gender="$(ez_get_argument --short '-g' --long '--gender' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pets="$(ez_get_argument --short '-p' --long '--pets' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local happy="$(ez_get_argument --short '-h' --long "--happy" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Title = ${title}"
    echo "Name = ${name}"
    echo "Gender = ${gender}"
    echo "Happy = ${happy}"
    echo "Pets = "; tr "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" "\n" <<< "${pets}"
    echo "Pets = "; ez_test_get_list "${pets}"
}

echo "[Test 1]"
ez_test_core_function_1 --help; echo

echo "[Test 2]"
ez_test_core_function_1 --name "EZ-QA" -g "Female" --happy --pets "Guinea Pig" "Bird" -t "Dr."; echo

echo "[Test 3]"
ez_test_core_function_1 --happy -t "Mr."; echo

echo "[Test 4]"
ez_test_core_function_1 --gender "Both Genders" --happy -t "Jr."; echo

echo "[Test 5]"
ez_test_core_function_1 --happy; echo



function ez_test_core_function_2() {
    if ! ez_function_exist; then
        ez_set_argument --short "-a1" --long "--argument-1" --required --info "The 1st argument" &&
        ez_set_argument --short "-a2" --long "--argument-2" --default "2nd Arg Def" --info "The 2nd argument" &&
        ez_set_argument --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" --info "The 3rd argument" &&
        ez_set_argument --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" --info "The list argument" &&
        ez_set_argument --short "-d" --long "--dry-run" --type "Flag" --info "The flag argument" || return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local arg_1="$(ez_get_argument --short "-a1" --long "--argument-1" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_2="$(ez_get_argument --short "-a2" --long "--argument-2" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_3="$(ez_get_argument --short "-a3" --long "--argument-3" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_l="$(ez_get_argument --short "-l" --long "--arg-list" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local dry_run="$(ez_get_argument --short '-d' --long "--dry-run" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; tr "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" "\n" <<< "${arg_l}"
    echo "Dry Run   : ${dry_run}"
}

echo "[Test 1]"
ez_test_core_function_2 --help; echo

echo "[Test 2]"
ez_test_core_function_2 -a1 "First Arg" -a2 "Second Arg" -a3 "Third Arg" -l "data1" "data2" "data3"; echo

echo "[Test 3]"
ez_test_core_function_2 -a2 "Second Arg" -a3 "Third Arg"; echo

echo "[Test 4]"
ez_test_core_function_2 -a1 "First Arg" -a3 "Third Arg"; echo

echo "[Test 5]"
ez_test_core_function_2 -a1 "First Arg" -a3 "Arg 3"; echo

echo "[Test 6]"
ez_test_core_function_2 -a1 "First Arg" --dry-run -a3 "3rd Arg"; echo


# function ez_test_core_function_3() {
#     if ! ez_function_exist; then
#         ez_set_argument --short "-c" --long "--choose-from" --choices "Choice 1" "Choice 2" --info "Test Choice" &&
#         ez_set_argument --short "-l" --long "--list-items" --type "List" --default "Item 1" "Item 2" --info "Test List & Default" || return 1
#     fi
#     ez_ask_for_help "${@}" && ez_function_help && return
#     local choose_from="$(ez_get_argument --short "-c" --long "--choose-from" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
#     local list_items="$(ez_get_argument --short "-l" --long "--list-items" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
#     echo "List:"; tr "${EZ_BASH_NON_SPACE_LIST_DELIMITER}" "\n" <<< "${list_items}"
#     echo "Choice: ${choose_from}"
# }
# 
# ez_test_core_function_3 --help
# 
# echo "${!EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP[@]}"
# echo "${EZ_BASH_FUNCTION_ARGUMENT_SHORT_NAME_TO_DEFAULT_MAP[@]}"

