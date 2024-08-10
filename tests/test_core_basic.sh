###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
source "${EZ_BASH_HOME}/tests/utils.sh" || exit 1
source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

###################################################################################################
# --------------------------------------- Test Function ----------------------------------------- #
###################################################################################################
TEST_FAILURE=0

function test_ez.lower {
    local expects=('aa1bb2cc(%@#&!$+-*/=.?"^{}|~)') results=("$(ez.lower 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')")
    ez.test.check --expects "expects" --results "results" --subject "Lowercase a single string" || ((++TEST_FAILURE))
    expects=("abc" "  def g*   &h "); results=("Abc" "  dEF g*   &H "); ez.lower "results" "${results[@]}"
    ez.test.check --expects "expects" --results "results" --subject "Lowercase an array of strings" || ((++TEST_FAILURE))
}

function test_ez.upper {
    local expects=('AA1BB2CC(%@#&!$+-*/=.?"^{}|~)') results=("$(ez.upper 'aA1Bb2cC(%@#&!$+-*/=.?"^{}|~)')")
    ez.test.check --expects "expects" --results "results" --subject "Uppercase a single string" || ((++TEST_FAILURE))
    expects=("ABC" "  DEF G*   &H "); results=("aBc" "  Def g*   &h "); ez.upper "results" "${results[@]}"
    ez.test.check --expects "expects" --results "results" --subject "Uppercase an array of strings" || ((++TEST_FAILURE))
}

function test_ez.quote {
    local expects=("' abc    def '") results=("$(ez.quote " abc    def ")")
    ez.test.check --expects "expects" --results "results" --subject "Quote a single string" || ((++TEST_FAILURE))
    expects=("'abc'" "'123'" "'''" "'  '"); results=("abc" "123" "'" "  "); ez.quote "results" "${results[@]}"
    ez.test.check --expects "expects" --results "results" --subject "Quote an array of strings" || ((++TEST_FAILURE))
}

function test_ez.quote.double {
    local expects=("\" abc    def \"") results=("$(ez.quote.double " abc    def ")")
    ez.test.check --expects "expects" --results "results" --subject "Double quote a single string" || ((++TEST_FAILURE))
    expects=("\"abc\"" "\"123\"" "\"\"\"" "\"  \""); results=("abc" "123" "\"" "  "); ez.quote.double "results" "${results[@]}"
    ez.test.check --expects "expects" --results "results" --subject "Double quote an array of strings" || ((++TEST_FAILURE))
}

function test_ez.includes {
    local expects=("True" "False") results=()
    if ez.includes 123 "abc" 123 "XYZ"; then results+=("True"); else results+=("False"); fi
    if ez.includes "xyz" "abc" 123 "XYZ"; then results+=("True"); else results+=("False"); fi
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.excludes {
    local expects=("False" "True") results=()
    if ez.excludes 123 "abc" 123 "XYZ"; then results+=("True"); else results+=("False"); fi
    if ez.excludes "xyz" "abc" 123 "XYZ"; then results+=("True"); else results+=("False"); fi
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.join {
    local expects=("abc-,123-,-,XYZ" ",xyz,,123,,,ABC,,")
    local results=("$(ez.join "-," "abc" "123" "" "XYZ")" "$(ez.join "," "" "xyz" "" "123" "" "" "ABC" "" "")")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.split {
    local expects=("" "abc" "123" "" "" "XYZ" "." "" "") results; ez.split "results" "," ",abc,123,,,XYZ,.,,"
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.time.today {
    local expects=("$(date '+%F')") results=("$(ez.time.today)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.time.now {
    local expects=("$(date '+%F %T %Z')") results=("$(ez.time.now)")
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.array.delete.item {
    local expects=("" "hello" "" "" "world" "") results=("" "3" "hello" "two" ""  "" "two" "world" "3" "3" "#" "")
    ez.array.delete.item "results" "two"
    ez.array.delete.item "results" "3"
    ez.array.delete.item "results" "#"
    ez.test.check --expects "expects" --results "results" --subject "Delete non-empty items" || ((++TEST_FAILURE))
    expects=("hello" "world"); ez.array.delete.item "results" ""
    ez.test.check --expects "expects" --results "results" --subject "Delete empty items" || ((++TEST_FAILURE))
}

function test_ez.array.delete.index {
    local expects=("" "hello" "" "world") results=("" "hello" "" "3" "world" "#" "")
    ez.array.delete.index "results" 3
    ez.array.delete.index "results" -1
    ez.array.delete.index "results" 4
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

function test_ez.string.count_items {
    local expects=(0 1 2 3 4 5 5)
    local results=(
        "$(ez.string.count_items ",")"
        "$(ez.string.count_items "," "abc")"
        "$(ez.string.count_items "," "a,bc")"
        "$(ez.string.count_items "," "a,b,c")"
        "$(ez.string.count_items "," ",a,b,c")"
        "$(ez.string.count_items "," ",a,b,c,")"
        "$(ez.string.count_items "@@" "@@123@@@xyz@@@@")"
    )
    ez.test.check --expects "expects" --results "results" || ((++TEST_FAILURE))
}

###################################################################################################
# ------------------------------------------ Run Test ------------------------------------------- #
###################################################################################################
test_ez.lower
test_ez.upper
test_ez.quote
test_ez.quote.double
test_ez.includes
test_ez.excludes
test_ez.join
test_ez.split

test_ez.time.today
test_ez.time.now

test_ez.array.delete.item
test_ez.array.delete.index

test_ez.string.count_items

exit "${TEST_FAILURE}"



