source "${EZ_BASH_HOME}/ez.sh" || exit 1

function ez.test.check {
    local -n ez_test_check_expects ez_test_check_results; local benchmark expect_item result_item subject error=0
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Compare results with benchmarks" \
        -a "-s|--subject" -t "String" -d "" -c "" -i "Test name" \
        -a "-e|--expects" -t "String" -d "" -c "" -i "Variable name of the benchmarks" \
        -a "-r|--results" -t "String" -d "" -c "" -i "Variable name of the results" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-s" | "--subject") shift; subject="${1}"; shift ;;
            "-e" | "--expects") shift; ez_test_check_expects="${1}"; shift ;;
            "-r" | "--results") shift; ez_test_check_results="${1}"; shift ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    if [[ "${#ez_test_check_expects[@]}" -ne "${#ez_test_check_results[@]}" ]]; then error=1; fi
    if [[ "${error}" -eq 1 ]]; then
        echo "[${FUNCNAME[1]}] ${subject}"
        echo -n "${EZ_INDENT}Expects (size: ${#ez_test_check_expects[@]}): "; ez.join ", " "${ez_test_check_expects[@]}"
        echo -n "${EZ_INDENT}Results (size: ${#ez_test_check_results[@]}): "; ez.join ", " "${ez_test_check_results[@]}"
        echo "${EZ_INDENT}Error: Array Size Unmatch!\n"
    else
        local i=0; for ((; i < "${#ez_test_check_expects[@]}"; ++i)); do
            expect_item="${ez_test_check_expects[${i}]}"
            result_item="${ez_test_check_results[${i}]}"
            if [[ "${#expect_item}" -ne "${#result_item}" ]]; then
                echo "[${FUNCNAME[1]}] ${subject}"
                echo "${EZ_INDENT}Expects[${i}] (length: ${#expect_item}): @${expect_item}@"
                echo "${EZ_INDENT}Results[${i}] (length: ${#result_item}): @${result_item}@"
                echo "${EZ_INDENT}Error: String Length Unmatch!"; error=1; break   
            fi
            if [[ "${expect_item}" != "${result_item}" ]]; then
                echo "[${FUNCNAME[1]}] ${subject}"
                echo "${EZ_INDENT}Expects[${i}]: ${expect_item}"
                echo "${EZ_INDENT}Results[${i}]: ${result_item}"
                echo "${EZ_INDENT}Error: Value Unmatch!"; error=1; break   
            fi
        done
    fi
    return "${error}"
}