###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/libs/string.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.string.trim {
    local string="///\/abc/d/e/"
    local expects=(
        # Left
        "//\/abc/d/e/"
        "/\/abc/d/e/"
        "\/abc/d/e/"
        # Right
        "///\/abc/d/e"
        "///\/abc/d/e"
        "///\/abc/d/e"
        # Both
        "//\/abc/d/e"
        "/\/abc/d/e"
        "\/abc/d/e"
        # Any
        "\abcde"
    )
    local results=(
        "$(ez.string.trim -k Left -c 1 -p "/" -s "${string}")"
        "$(ez.string.trim -k Left -c 2 -p "/" -s "${string}")"
        "$(ez.string.trim -k Left -p "/" -s "${string}")"
        "$(ez.string.trim -k Right -c 1 -p "/" -s "${string}")"
        "$(ez.string.trim -k Right -c 2 -p "/" -s "${string}")"
        "$(ez.string.trim -k Right -p "/" -s "${string}")"
        "$(ez.string.trim -k Both -c 1 -p "/" -s "${string}")"
        "$(ez.string.trim -k Both -c 2 -p "/" -s "${string}")"
        "$(ez.string.trim -k Both -p "/" -s "${string}")"
        "$(ez.string.trim -p "/" -s "${string}")"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}


###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.string.trim

exit "${TEST_FAILURE}"
