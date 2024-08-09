###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.string.lower {
    local benchmark='aa1bb2cc(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez.string.lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.upper {
    local benchmark='AA1BB2CC(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez.string.upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.time.today {
    local benchmark="$(date '+%F')"
    local result="$(ez.time.today)"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.time.now {
    local benchmark="$(date '+%F %T %Z')"
    local result="$(ez.time.now)"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.quote {
    local benchmarks=("'abc'" "'123'" "'''" "'  '")
    local results=("abc" "123" "'" "  "); ez.quote "results" "${results[@]}"
    ez.test.check --benchmarks "${benchmarks[@]}" --results "${results[@]}" || ((++TEST_FAILURE))
}

function test_ez.double_quote {
    local benchmarks=("\"abc\"" "\"123\"" "\"\"\"" "\"  \"")
    local results=("abc" "123" "\"" "  "); ez.double_quote "results" "${results[@]}"
    ez.test.check --benchmarks "${benchmarks[@]}" --results "${results[@]}" || ((++TEST_FAILURE))
}

function test_ez.string.join {
    local benchmark="abc-,123-,-,XYZ"
    local result="$(ez.string.join "-," "abc" "123" "" "XYZ")"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.includes {
    local result
    ez.includes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez.test.check --benchmarks "True" --results "${result}" || ((++TEST_FAILURE))
    ez.includes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez.test.check --benchmarks "False" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.excludes {
    local result
    ez.excludes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez.test.check --benchmarks "False" --results "${result}" || ((++TEST_FAILURE))
    ez.excludes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez.test.check --benchmarks "True" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.count_items {
    local benchmark=5
    local result="$(ez.string.count_items "@@" "@@123@@@xyz@@@@")"
    ez.test.check --benchmarks "${benchmark}" --results "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.split {
    local benchmark=("abc" "123" "" "XYZ" ".") result
    ez.string.split "result" "," "abc,123,,XYZ,."
    local i; for ((i=0; i<${#benchmark[@]}; ++i)); do
        ez.test.check --benchmarks "${benchmark[${i}]}" --results "${result[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez.array.delete_item {
    local array=("one" "two" "three" "four" "five")
    local benchmark=("two" "four")
    ez.array.delete_item array "three"
    ez.array.delete_item array "five"
    ez.array.delete_item array "one"
    local i; for ((i=0; i<${#benchmark[@]}; ++i)); do
        ez.test.check --benchmarks "${benchmark[${i}]}" --results "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez.array.delete_index {
    local array=("one" "two" "three" "four" "five")
    local benchmark=("two" "four")
    ez.array.delete_item array 2
    ez.array.delete_item array -1
    ez.array.delete_item array 0
    local i; for ((i=0; i<${#benchmark[@]}; ++i)); do
        ez.test.check --benchmarks "${benchmark[${i}]}" --results "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.quote
test_ez.double_quote
test_ez.includes
test_ez.excludes
test_ez.array.delete_item

test_ez.string.count_items
test_ez.string.split
test_ez.string.join
test_ez.string.lower
test_ez.string.upper

test_ez.time.today
test_ez.time.now


exit "${TEST_FAILURE}"



