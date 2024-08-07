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
    local expect='aa1bb2cc(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez.string.lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.upper {
    local expect='AA1BB2CC(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez.string.upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.time.today {
    local expect="$(date '+%F')"
    local result="$(ez.time.today)"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.time.now {
    local expect="$(date '+%F %T %Z')"
    local result="$(ez.time.now)"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.array.quote {
    local expect="'abc' '123' ''' '  '"
    local result="$(ez.array.quote "abc" "123" "'" "  ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.array.double_quote {
    local expect="\"abc\" \"123\" \"\"\" \"  \""
    local result="$(ez.array.double_quote "abc" "123" "\"" "  ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.join {
    local expect="abc-,123-,-,XYZ"
    local result="$(ez.string.join "-," "abc" "123" "" "XYZ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.array.includes {
    local result
    ez.array.includes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "True" "${result}" || ((++TEST_FAILURE))
    ez.array.includes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "False" "${result}" || ((++TEST_FAILURE))
}

function test_ez.array.excludes {
    local result
    ez.array.excludes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "False" "${result}" || ((++TEST_FAILURE))
    ez.array.excludes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.count_items {
    local expect=5
    local result="$(ez.string.count_items "@@" "@@123@@@xyz@@@@")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez.string.split {
    local expect=("abc" "123" "" "XYZ" ".") result
    ez.string.split "result" "," "abc,123,,XYZ,."
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${result[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez.array.delete_item {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ez.array.delete_item array "three"
    ez.array.delete_item array "five"
    ez.array.delete_item array "one"
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez.array.delete_index {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ez.array.delete_item array 2
    ez.array.delete_item array -1
    ez.array.delete_item array 0
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

test_ez.string.lower
test_ez.string.upper
test_ez.time.today
test_ez.time.now
test_ez.array.quote
test_ez.array.double_quote
test_ez.string.join
test_ez.array.includes
test_ez.array.excludes
test_ez.string.count_items
test_ez.string.split
test_ez.array.delete_item

exit "${TEST_FAILURE}"



