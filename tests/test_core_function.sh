###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1

function registered_function {
    if ez.function.unregistered; then
        ez.argument.set --short "-r" --long "--required-arg" --required &&
        ez.argument.set --short "-d" --long "--default-arg" --default "A default string" &&
        ez.argument.set --short "-c" --long "--choices-arg" --choices "Choice 1" "Choice 2" "Choice 3" &&
        ez.argument.set --short "-f" --long "--flag-arg" --type "Flag" &&
        ez.argument.set --short "-l" --long "--list-arg" --type "List" --default "Def 1" "Def 2" "Def 3" &&
        ez.argument.set --short "-b" --long "--buy-arg" --exclude "order" &&
        ez.argument.set --short "-s" --long "--sell-arg" --exclude "order" || return 1
    fi; ez.function.help "${@}" --run-with-no-arguments || return 0
    local required_arg && required_arg="$(ez.argument.get --short "-r" --long "--required-arg" --arguments "${@}")" &&
    local default_arg && default_arg="$(ez.argument.get --short "-d" --long "--default-arg" --arguments "${@}")" &&
    local choices_arg && choices_arg="$(ez.argument.get --short "-c" --long "--choices-arg" --arguments "${@}")" &&
    local flag_arg && flag_arg="$(ez.argument.get --short "-f" --long "--flag-arg" --arguments "${@}")" &&
    local list_arg && ez.function.arguments.get_list "list_arg" "$(ez.argument.get --short "-l" --long "--list-arg" --arguments "${@}")" &&
    local buy_arg && buy_arg="$(ez.argument.get --short "-b" --long "--buy-arg" --arguments "${@}")" &&
    local sell_arg && sell_arg="$(ez.argument.get --short "-s" --long "--sell-arg" --arguments "${@}")" || return 1
    echo "default_arg: ${default_arg}"
    echo "flag_arg: ${flag_arg}"
    local l; for l in "${list_arg[@]}"; do echo "list_arg: ${l}"; done
}

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.argument.get.string.required {
    local error_output="$(registered_function 2>&1)" expects=("True") results=()
    [[  "${error_output}" =~ "Argument \"-r\" is required" ]] && results+=("True") || results+=("False")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.argument.get.string.exclude {
    local error_output="$(registered_function -r '' -b -s 2>&1)" expects=("True") results=()
    [[  "${error_output}" =~ "\"-b\" and \"-s\" are mutually exclusive in group: order" ]] && results+=("True") || results+=("False")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.argument.get.string.choices {
    local error_output="$(registered_function -r '' -c 'My Choice' 2>&1)" expects=("True" "True") results=()
    [[  "${error_output}" =~ "Invalid value \"My Choice\" for \"-c\"" ]] && results+=("True") || results+=("False")
    [[  "${error_output}" =~ "please choose from [Choice 1, Choice 2, Choice 3]" ]] && results+=("True") || results+=("False")
    ez.test.check --expects "expects" --results "results" --subject "Invalid Choices" || ((++TEST_FAILURE))
}

function test_ez.argument.get.string.default {
    local expects=("default_arg: A default string") results=("$(registered_function -r '' | grep 'default_arg')")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.argument.get.list.default {
    local expects=(
        "list_arg: Def 1"
        "list_arg: Def 2"
        "list_arg: Def 3"
    )
    local results=()
    local line; while read -rd $'\n' line; do results+=("${line}"); done < <(registered_function -r "" | grep "list_arg")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.argument.get.flag {
    local expects=(
        "flag_arg: True"
        "flag_arg: False"
    )
    local results=(
        "$(registered_function -r '' -f | grep 'flag_arg')"
        "$(registered_function -r '' | grep 'flag_arg')"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.argument.get.string.required
test_ez.argument.get.string.exclude
test_ez.argument.get.string.choices
test_ez.argument.get.string.default

test_ez.argument.get.list.default
test_ez.argument.get.flag

exit "${TEST_FAILURE}"


