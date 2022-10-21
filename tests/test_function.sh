###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/core/basic.sh" || exit 1
source "${EZ_BASH_HOME}/core/function.sh" || exit 1

function registered_function() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-r" --long "--required-arg" --required &&
        ezb_arg_set --short "-d" --long "--default-arg" --default "A default string" &&
        ezb_arg_set --short "-c" --long "--choices-arg" --choices "Choice 1" "Choice 2" "Choice 3" &&
        ezb_arg_set --short "-f" --long "--flag-arg" --type "Flag" &&
        ezb_arg_set --short "-l" --long "--list-arg" --type "List" --default "Def 1" "Def 2" "Def 3" &&
        ezb_arg_set --short "-b" --long "--buy-arg" --exclude "order" &&
        ezb_arg_set --short "-s" --long "--sell-arg" --exclude "order" || return 1
    fi
    [[ -n "${@}" ]] && ezb_function_usage "${@}" && return
    local required_arg && required_arg="$(ezb_arg_get --short "-r" --long "--required-arg" --arguments "${@}")" &&
    local default_arg && default_arg="$(ezb_arg_get --short "-d" --long "--default-arg" --arguments "${@}")" &&
    local choices_arg && choices_arg="$(ezb_arg_get --short "-c" --long "--choices-arg" --arguments "${@}")" &&
    local flag_arg && flag_arg="$(ezb_arg_get --short "-f" --long "--flag-arg" --arguments "${@}")" &&
    local list_arg && list_arg="$(ezb_arg_get --short "-l" --long "--list-arg" --arguments "${@}")" &&
    local buy_arg && buy_arg="$(ezb_arg_get --short "-b" --long "--buy-arg" --arguments "${@}")" &&
    local sell_arg && sell_arg="$(ezb_arg_get --short "-s" --long "--sell-arg" --arguments "${@}")" || return 1
    echo "default_arg: ${default_arg}"
    echo "flag_arg: ${flag_arg}"
    echo "list_arg: ${list_arg}"
}

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_string_required() {
    local error_output="$(registered_function 2>&1)" result
    [[  "${error_output}" =~ "Argument \"-r\" is required" ]] && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_string_exclude() {
    local error_output="$(registered_function -r '' -b -s 2>&1)" result
    [[  "${error_output}" =~ "\"-b\" and \"-s\" are mutually exclusive in group: order" ]] && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_string_choices() {
    local error_output="$(registered_function -r '' -c 'My Choice' 2>&1)" result
    [[  "${error_output}" =~ "Invalid value \"My Choice\" for argument \"-c\"" ]] && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
    [[  "${error_output}" =~ "Please choose from [Choice 1, Choice 2, Choice 3] for argument \"-c\"" ]] && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_string_default() {
    ezb_expect_result "default_arg: A default string" "$(registered_function -r '' | grep 'default_arg')" || ((++TEST_FAILURE))
}

function test_list_default() {
    ezb_expect_result "list_arg: Def 1#Def 2#Def 3" "$(registered_function -r '' | grep 'list_arg')" || ((++TEST_FAILURE))   
}

function test_flag() {
    ezb_expect_result "flag_arg: True" "$(registered_function -r '' -f | grep 'flag_arg')" || ((++TEST_FAILURE))
    ezb_expect_result "flag_arg: False" "$(registered_function -r '' | grep 'flag_arg')" || ((++TEST_FAILURE))
}

test_string_required
test_string_exclude
test_string_choices
test_string_default
test_list_default
test_flag

exit "${TEST_FAILURE}"


