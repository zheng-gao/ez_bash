###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
[[ -z "${EZ_BASH_HOME}" ]] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1
source "${EZ_BASH_HOME}/ezb/ezb.sh" || exit 1
source "${EZ_BASH_HOME}/ezb/ezb_function.sh" || exit 1

###################################################################################################
# --------------------------------------- Main Function ----------------------------------------- #
###################################################################################################
function ezb_test_string_arg_required() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

ezb_test_string_arg_required
ezb_test_string_arg_required -i "hello world"

function ezb_test_string_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --default "A default string" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}

ezb_test_string_arg_default
ezb_test_string_arg_default -i "hello world"

function ezb_test_string_arg_choices() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-i" --long "--input" --required --choices "Cappuccino" "Espresso" "Latte" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local input && input="$(ezb_arg_get --short "-i" --long "--input" --arguments "${@}")" || return 1
    echo "input = \"${input}\""
}
ezb_test_string_arg_choices -i "Americano"
ezb_test_string_arg_choices -i "Latte"

function ezb_test_password_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-p" --long "--password" --required --type "Password" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local password && password="$(ezb_arg_get --short "-p" --long "--password" --arguments "${@}")" || return 1
    echo "$(ezb_string_repeat --string "*" --count ${#password})"
    echo "password = \"${password}\""
}
ezb_test_password_arg

function ezb_test_list_arg_default() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-l" --long "--list" --default "Def 1" "Def 2" "Def 3" --type "List" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local list && list="$(ezb_arg_get --short "-l" --long "--list" --arguments "${@}")" || return 1
    ezb_function_get_list "${list}"
}
ezb_test_list_arg_default
ezb_test_list_arg_default -l "Item 1" "Item 2" "Item 3"

function ezb_test_flag_arg() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-f" --long "--flag" --type "Flag" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local flag && flag="$(ezb_arg_get --short "-f" --long "--flag" --arguments "${@}")" || return 1
    echo "flag = ${flag}"
}
ezb_test_flag_arg
ezb_test_flag_arg --flag

function ezb_test_core_function_1() {
    if ezb_function_unregistered; then
        ezb_arg_set -s "-t" --required -i "Your Title" &&
        ezb_arg_set --short "-n" --long "--name" --default "Tester" --info "Your Name" &&
        ezb_arg_set -s "-g" --long "--gender" -d "Both Genders" --choices "Both Genders" "Male" "Female" --info "Your Gender" &&
        ezb_arg_set -s "-p" -l "--pets" --type "List" -d "Chiwawa Dog" "Cat" "Beta Fish" -i "Pets List" &&
        ezb_arg_set -s "-h" -l "--happy" -t "Flag" || return 1
    fi
    ezb_function_usage "${@}" && return
    local title && title="$(ezb_arg_get --short "-t" --arguments "${@}")" &&
    local name && name="$(ezb_arg_get --short "-n" --long "--name" --arguments "${@}")" &&
    local gender && gender="$(ezb_arg_get --short "-g" --long "--gender" --arguments "${@}")" &&
    local pets && pets="$(ezb_arg_get --short "-p" --long "--pets" --arguments "${@}")" &&
    local happy && happy="$(ezb_arg_get --short "-h" --long "--happy" --arguments "${@}")" || return 1
    echo "Title = ${title}"
    echo "Name = ${name}"
    echo "Gender = ${gender}"
    echo "Happy = ${happy}"
    echo "Pets = "; tr "${EZB_CHAR_NON_SPACE_DELIMITER}" "\n" <<< "${pets}"
    echo "Pets = "; ezb_split "${EZB_CHAR_NON_SPACE_DELIMITER}" "${pets}"
}

echo "[Test 1]"
ezb_test_core_function_1 --help; echo

echo "[Test 2]"
ezb_test_core_function_1 --name "EZ-QA" -g "Female" --happy --pets "Guinea Pig" "Bird" -t "Dr."; echo

echo "[Test 3]"
ezb_test_core_function_1 --happy -t "Mr."; echo

echo "[Test 4]"
ezb_test_core_function_1 --gender "Both Genders" --happy -t "Jr."; echo

echo "[Test 5]"
ezb_test_core_function_1 --happy; echo



function ezb_test_core_function_2() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-a1" --long "--argument-1" --required --info "The 1st argument" &&
        ezb_arg_set --short "-a2" --long "--argument-2" --default "2nd Arg Def" --info "The 2nd argument" &&
        ezb_arg_set --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" --info "The 3rd argument" &&
        ezb_arg_set --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" --info "The list argument" &&
        ezb_arg_set --short "-d" --long "--dry-run" --type "Flag" --info "The flag argument" || return 1
    fi
    ezb_function_usage "${@}" && return
    local arg_1 && arg_1="$(ezb_arg_get --short "-a1" --long "--argument-1" --arguments "${@}")" &&
    local arg_2 && arg_2="$(ezb_arg_get --short "-a2" --long "--argument-2" --arguments "${@}")" &&
    local arg_3 && arg_3="$(ezb_arg_get --short "-a3" --long "--argument-3" --arguments "${@}")" &&
    local arg_l && arg_l="$(ezb_arg_get --short "-l" --long "--arg-list" --arguments "${@}")" &&
    local dry_run && dry_run="$(ezb_arg_get --short "-d" --long "--dry-run" --arguments "${@}")" || return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; tr "${EZB_CHAR_NON_SPACE_DELIMITER}" "\n" <<< "${arg_l}"
    echo "Dry Run   : ${dry_run}"
}

echo "[Test 1]"
ezb_test_core_function_2 --help; echo

echo "[Test 2]"
ezb_test_core_function_2 -a1 "First Arg" -a2 "Second Arg" -a3 "Third Arg" -l "data1" "data2" "data3"; echo

echo "[Test 3]"
ezb_test_core_function_2 -a2 "Second Arg" -a3 "Third Arg"; echo

echo "[Test 4]"
ezb_test_core_function_2 -a1 "First Arg" -a3 "Third Arg"; echo

echo "[Test 5]"
ezb_test_core_function_2 -a1 "First Arg" -a3 "Arg 3"; echo

echo "[Test 6]"
ezb_test_core_function_2 -a1 "First Arg" --dry-run -a3 "3rd Arg"; echo


