###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ezb_lower {
    local expect='aa1bb2cc(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ezb_lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_upper {
    local expect='AA1BB2CC(%@#&!$+-*/=.?"^{}|~)'
    local result="$(ezb_upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_today {
    local expect="$(date '+%F')"
    local result="$(ezb_today)"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_now {
    local expect="$(date '+%F %T')"
    local result="$(ezb_now)"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_quote {
    local expect="'abc' '123' ''' '  '"
    local result="$(ezb_quote "abc" "123" "'" "  ")"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_double_quote {
    local expect="\"abc\" \"123\" \"\"\" \"  \""
    local result="$(ezb_double_quote "abc" "123" "\"" "  ")"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_join {
    local expect="abc-,123-,-,XYZ"
    local result="$(ezb_join "-," "abc" "123" "" "XYZ")"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_contains {
    local result
    ezb_contains "123" "abc" "123" "XYZ" && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
    ezb_contains "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ezb_expect_result "False" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_excludes {
    local result
    ezb_excludes "123" "abc" "123" "XYZ" && result="True" || result="False"
    ezb_expect_result "False" "${result}" || ((++TEST_FAILURE))
    ezb_excludes "xyz" "abc" "123" "XYZ" && result="True" || result="False"
    ezb_expect_result "True" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_count_items {
    local expect=5
    local result="$(ezb_count_items "@@" "@@123@@@xyz@@@@")"
    ezb_expect_result "${expect}" "${result}" || ((++TEST_FAILURE))
}

function test_ezb_split {
    local expect=("abc" "123" "" "XYZ" ".") result
    ezb_split "result" "," "abc,123,,XYZ,."
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ezb_expect_result "${expect[${i}]}" "${result[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ezb_array_delete_item {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ezb_array_delete_item array "three"
    ezb_array_delete_item array "five"
    ezb_array_delete_item array "one"
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ezb_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

function test_ezb_array_delete_index {
    local array=("one" "two" "three" "four" "five")
    local expect=("two" "four")
    ezb_array_delete_item array 2
    ezb_array_delete_item array -1
    ezb_array_delete_item array 0
    local i; for ((i=0; i<${#expect[@]}; ++i)); do
        ezb_expect_result "${expect[${i}]}" "${array[${i}]}" || ((++TEST_FAILURE))
    done
}

test_ezb_lower
test_ezb_upper
test_ezb_today
test_ezb_now
test_ezb_quote
test_ezb_double_quote
test_ezb_join
test_ezb_contains
test_ezb_excludes
test_ezb_count_items
test_ezb_split
test_ezb_array_delete_item

exit "${TEST_FAILURE}"



