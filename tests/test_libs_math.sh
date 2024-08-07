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
    local expects_and_results=(
        0 "$(ez.math.floor 0.1)"
        1 "$(ez.math.floor 1.7)"
        2 "$(ez.math.floor 2.00)"
        3 "$(ez.math.floor 3)"
        4 "$(ez.math.floor 4.5)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.ceiling {
    local expects_and_results=(
        1 "$(ez.math.ceiling 0.1)"
        2 "$(ez.math.ceiling 1.7)"
        2 "$(ez.math.ceiling 2.00)"
        3 "$(ez.math.ceiling 3)"
        5 "$(ez.math.ceiling 4.5)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.min {
    local expects_and_results=(
        -5 "$(ez.math.min 3 -2 1 -5 0 4)"
        -0.88 "$(ez.math.min 1.7 2.00 -0.88 4.5 3)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.max {
    local expects_and_results=(
        4 "$(ez.math.max 3 -2 1 -5 0 4)"
        4.5 "$(ez.math.max 1.7 2.00 -0.88 4.5 3)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.sum {
    local expects_and_results=(
        1 "$(ez.math.sum 3 -2 1 -5 0 4)"
        10.32 "$(ez.math.sum 1.7 2.00 -0.88 4.5 3)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.average {
    local expects_and_results=(
        0.166 "$(ez.math.average --data 3 -2 1 -5 0 4 --scale 3)"
        2.0640 "$(ez.math.average --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.variance {
    local expects_and_results=(
        10.966 "$(ez.math.variance --data 3 -2 1 -5 0 4 --scale 3)"
        3.9033 "$(ez.math.variance --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
}

function test_ez.math.std_deviation {
    local expects_and_results=(
        3.311 "$(ez.math.std_deviation --data 3 -2 1 -5 0 4 --scale 3)"
        1.9756 "$(ez.math.std_deviation --data 1.7 2.00 -0.88 4.5 3 --scale 4)"
    )
    local i expect result; for ((i=0; i < "${#expects_and_results[@]}" - 1; i+=2)); do
        ez_expect_result "${expects_and_results[${i}]}" "${expects_and_results[$((i+1))]}" || ((++TEST_FAILURE))
    done
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



