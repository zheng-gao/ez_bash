###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
[[ -z "${EZ_BASH_HOME}" ]] && echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!" && exit 1

if ! source "${EZ_BASH_HOME}/ezb/ezb_core.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ezb/ezb_function.sh"; then exit 1; fi

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
        if [ "${char}" = "${EZB_CHAR_NON_SPACE_DELIMITER}" ]; then
            [ -n "${item}" ] && echo "${item}"
            item=""
        else
            item+="${char}"
        fi
        [ "${k}" -eq "${last_index}" ] && [ -n "${item}" ] && echo "${item}"
    done
}

function ez_test_core_function_1() {
    if ! ezb_function_exist; then
        ezb_set_arg -s "-t" --required -i "Your Title" &&
        ezb_set_arg --short "-n" --long "--name" --default "Tester" --info "Your Name" &&
        ezb_set_arg -s "-g" --long "--gender" -d "Both Genders" --choices "Both Genders" "Male" "Female" --info "Your Gender" &&
        ezb_set_arg -s "-p" -l "--pets" --type "List" -d "Chiwawa Dog" "Cat" "Beta Fish" -i "Pets List" &&
        ezb_set_arg -s "-h" -l "--happy" -t "Flag" || return 1
    fi
    ezb_function_usage "${@}" && return
    local title; title="$(ez_get_arg --short '-t' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local name; name="$(ez_get_arg --short '-n' --long '--name' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local gender; gender="$(ezb_get_arg --short '-g' --long '--gender' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local pets; pets="$(ezb_get_arg --short '-p' --long '--pets' --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local happy; happy="$(ezb_get_arg --short '-h' --long "--happy" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Title = ${title}"
    echo "Name = ${name}"
    echo "Gender = ${gender}"
    echo "Happy = ${happy}"
    echo "Pets = "; tr "${EZB_CHAR_NON_SPACE_DELIMITER}" "\n" <<< "${pets}"
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
    if ! ezb_function_exist; then
        ezb_set_arg --short "-a1" --long "--argument-1" --required --info "The 1st argument" &&
        ezb_set_arg --short "-a2" --long "--argument-2" --default "2nd Arg Def" --info "The 2nd argument" &&
        ezb_set_arg --short "-a3" --long "--argument-3" --choices "3rd Arg" "Third Arg" --info "The 3rd argument" &&
        ezb_set_arg --short "-l" --long "--arg-list" --type "List" --default "Item 1" "Item 2" --info "The list argument" &&
        ezb_set_arg --short "-d" --long "--dry-run" --type "Flag" --info "The flag argument" || return 1
    fi
    ezb_function_usage "${@}" && return
    local arg_1; arg_1="$(ezb_get_arg --short "-a1" --long "--argument-1" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_2; arg_2="$(ezb_get_arg --short "-a2" --long "--argument-2" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_3; arg_3="$(ezb_get_arg --short "-a3" --long "--argument-3" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local arg_l; arg_l="$(ezb_get_arg --short "-l" --long "--arg-list" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local dry_run; dry_run="$(ezb_get_arg --short '-d' --long "--dry-run" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    echo "Argument 1: ${arg_1}"
    echo "Argument 2: ${arg_2}"
    echo "Argument 3: ${arg_3}"
    echo "Argument List:"; tr "${EZB_CHAR_NON_SPACE_DELIMITER}" "\n" <<< "${arg_l}"
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


