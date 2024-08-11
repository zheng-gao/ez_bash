###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/function.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/pipeable.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.pipe.strip {
    local expects=("$(printf 'a bc\t def')") results=("$(printf '  \ta bc\t def  \t ' | ez.pipe.strip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.pipe.lstrip {
    local expects=("$(printf 'a bc\t def  \t ')") results=("$(printf '  \ta bc\t def  \t ' | ez.pipe.lstrip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.pipe.rstrip {
    local expects=("$(printf '  \ta bc\t def')") results=("$(printf '  \ta bc\t def  \t ' | ez.pipe.rstrip)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.pipe.stats {
    local expects=("$(printf '   1 d\n   2 c\n   3 a\n   4 b\n')") results=("$(printf 'b\na\nb\nc\nb\nd\na\na\nc\nb\n' | ez.pipe.stats)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.pipe.versions {
    local expects=("1.2.3" "1.22.33" "0.00.000.0000.00000")
    local results=($(
        {
            echo "1.2.3version at the beginning."
            echo "Version v1.22.33 mixed with invalid versions 1..2."
            echo "Four digits version: 0.00.000.0000.00000"
        } | ez.pipe.versions
    ))
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.pipe.columns.get {
    local expects=(
        "a d b"
        "a#d#b"
        "a d "
        "a&d&c&&&b"
    )
    local results=(
        "$(echo "a    b c d" | ez.pipe.columns.get -c 1 -1 2)"
        "$(echo "a    b c d" | ez.pipe.columns.get -od "#" -c 1 -1 2)"
        "$(echo "a@@@@b@c@d" | ez.pipe.columns.get -id "@" -c 1 -1 2)"
        "$(echo 'a!!!!b!c!d' | ez.pipe.columns.get -id "!" -od "&" -c 1 -1 -2 3 4 5)"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.pipe.strip
test_ez.pipe.lstrip
test_ez.pipe.rstrip
test_ez.pipe.stats
test_ez.pipe.versions

test_ez.pipe.columns.get

exit "${TEST_FAILURE}"

