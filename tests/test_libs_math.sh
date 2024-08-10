###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/function.sh" || exit 1
source "${EZ_BASH_HOME}/src/libs/math.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.math.floor {
    local expects=(0 1 2 3 4) results=($(for data in 0.1 1.7 2.00 3 4.5; do ez.math.floor "${data}"; done))
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.ceiling {
    local expects=(1 2 2 3 5) results=($(for data in 0.1 1.7 2.00 3 4.5; do ez.math.ceiling "${data}"; done))
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.min {
    local expects=(-5 -0.88) results=("$(ez.math.min 3 -2 1 -5 0 4)" "$(ez.math.min 1.7 2.00 -0.88 4.5 3)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.max {
    local expects=(4 4.5) results=("$(ez.math.max 3 -2 1 -5 0 4)" "$(ez.math.max 1.7 2.00 -0.88 4.5 3)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.sum {
    local expects=(1 10.32) results=("$(ez.math.sum 3 -2 1 -5 0 4)" "$(ez.math.sum 1.7 2.00 -0.88 4.5 3)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.average {
    local expects=(0.166 2.0640)
    local results=(
        "$(ez.math.average --data 3 -2 1 -5 0 4 --scale 3)"
        "$(ez.math.average --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.variance {
    local expects=(10.966 3.9033)
    local results=(
        "$(ez.math.variance --data 3 -2 1 -5 0 4 --scale 3)"
        "$(ez.math.variance --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.math.std_deviation {
    local expects=(3.311 1.9756)
    local results=(
        "$(ez.math.std_deviation --data 3 -2 1 -5 0 4 --scale 3)"
        "$(ez.math.std_deviation --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.math.floor
test_ez.math.ceiling
test_ez.math.min
test_ez.math.max
test_ez.math.sum
test_ez.math.average
test_ez.math.variance
test_ez.math.std_deviation

exit "${TEST_FAILURE}"



