###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/pipeable.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_EZP_STRIP {
    local benchmark="$(printf 'a bc\t def')"
    local result=$(printf '  \ta bc\t def  \t ' | EZP_STRIP)
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_EZP_LSTRIP {
    local benchmark="$(printf 'a bc\t def  \t ')"
    local result=$(printf '  \ta bc\t def  \t ' | EZP_LSTRIP)
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_EZP_RSTRIP {
    local benchmark="$(printf '  \ta bc\t def')"
    local result=$(printf '  \ta bc\t def  \t ' | EZP_RSTRIP)
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_EZP_STATS {
    local benchmark="$(printf '   1 d\n   2 c\n   3 a\n   4 b\n')"
    local result=$(printf 'b\na\nb\nc\nb\nd\na\na\nc\nb\n' | EZP_STATS)
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_EZP_STRIP
test_EZP_LSTRIP
test_EZP_RSTRIP
test_EZP_STATS

exit "${TEST_FAILURE}"



