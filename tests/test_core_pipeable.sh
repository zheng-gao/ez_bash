###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/pipeable.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_EZ_PIPE_STRIP {
    local expect="$(printf 'a bc\t def')"
    local result=$(printf '  \ta bc\t def  \t ' | EZ_PIPE_STRIP)
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_EZ_PIPE_LSTRIP {
    local expect="$(printf 'a bc\t def  \t ')"
    local result=$(printf '  \ta bc\t def  \t ' | EZ_PIPE_LSTRIP)
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_EZ_PIPE_RSTRIP {
    local expect="$(printf '  \ta bc\t def')"
    local result=$(printf '  \ta bc\t def  \t ' | EZ_PIPE_RSTRIP)
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

test_EZ_PIPE_STRIP
test_EZ_PIPE_LSTRIP
test_EZ_PIPE_RSTRIP

exit "${TEST_FAILURE}"



