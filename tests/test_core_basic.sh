###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez_lower {
    local expect='aa1bb2cc(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez_lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_upper {
    local expect='AA1BB2CC(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ez_upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_today {
    local expect="$(date '+%F')"
    local result="$(ez_today)"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_now {
    local expect="$(date '+%F %T')"
    local result="$(ez_now)"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_quote {
    local expect="'abc' '123' ''' '  '"
    local result="$(ez_quote "abc" "123" "'" "  ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_double_quote {
    local expect="\"abc\" \"123\" \"\"\" \"  \""
    local result="$(ez_double_quote "abc" "123" "\"" "  ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_join {
    local expect="abc-,123-,-,XYZ"
    local result="$(ez_join "-," "abc" "123" "" "XYZ")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_contains {
    local result
    ez_contains "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "True" "${result}" || ((++TEST_FAILURE))
    ez_contains "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "False" "${result}" || ((++TEST_FAILURE))
}

function test_ez_excludes {
    local result
    ez_excludes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "False" "${result}" || ((++TEST_FAILURE))
    ez_excludes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ez_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_ez_count_items {
    local expect=5
    local result="$(ez_count_items "@@" "@@123@@@xyz@@@@")"
    ez_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ez_split {
    local expect=("abc" "123" "" "XYZ" ".") result
    ez_split "result" "," "abc,123,,XYZ,."
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${result[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez_array_delete_item {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ez_array_delete_item array "three"
    ez_array_delete_item array "five"
    ez_array_delete_item array "one"
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ez_array_delete_index {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ez_array_delete_item array 2
    ez_array_delete_item array -1
    ez_array_delete_item array 0
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ez_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

test_ez_lower
test_ez_upper
test_ez_today
test_ez_now
test_ez_quote
test_ez_double_quote
test_ez_join
test_ez_contains
test_ez_excludes
test_ez_count_items
test_ez_split
test_ez_array_delete_item

exit "${TEST_FAILURE}"



