###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.strip {
    local expects=("$(printf 'a bc\t def')") results=("$(printf '  \ta bc\t def  \t ' | ez.strip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.lstrip {
    local expects=("$(printf 'a bc\t def  \t ')") results=("$(printf '  \ta bc\t def  \t ' | ez.lstrip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.rstrip {
    local expects=("$(printf '  \ta bc\t def')") results=("$(printf '  \ta bc\t def  \t ' | ez.rstrip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.stats {
    local expects=("$(printf '   1 d\n   2 c\n   3 a\n   4 b\n')") results=("$(printf 'b\na\nb\nc\nb\nd\na\na\nc\nb\n' | ez.stats)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.versions {
    local expects=("1.2.3" "1.22.33" "0.00.000.0000.00000")
    local results=($(
        {
            echo "1.2.3version at the beginning."
            echo "Version v1.22.33 mixed with invalid versions 1..2."
            echo "Four digits version: 0.00.000.0000.00000"
        } | ez.versions
    ))
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.strip
test_ez.lstrip
test_ez.rstrip
test_ez.stats
test_ez.versions

exit "${TEST_FAILURE}"
