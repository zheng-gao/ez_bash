###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/core/basic.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
HAS_ERROR="False"

function test_ezb_lower() {
    local expect='aa1bb2cc(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ezb_lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ezb_expect_result "${expect}" "${result}" || HAS_ERROR="True"
}

function test_ezb_upper() {
    local expect='AA1BB2CC(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ezb_upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ezb_expect_result "${expect}" "${result}" || HAS_ERROR="True"
}

test_ezb_lower
test_ezb_upper

[[ "${HAS_ERROR}" = "True" ]] && exit 1 || exit 0
