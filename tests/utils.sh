source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

function ez.test.check {
    local -n ez_test_check_expects ez_test_check_results; local benchmark result subject error=0
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
        echo -n "${EZ_INDENT}Expects: "; ez.join ", " "${ez_test_check_expects[@]}"
        echo -n "${EZ_INDENT}Results: "; ez.join ", " "${ez_test_check_results[@]}"
        echo "${EZ_INDENT}  Error: Lengths Unmatch!"
        echo
    else
        local i; for i in "${!ez_test_check_expects[@]}"; do
            if [[ "${ez_test_check_expects[${i}]}" != "${ez_test_check_results[${i}]}" ]]; then
                echo "[${FUNCNAME[1]}] ${subject}"
                echo "${EZ_INDENT}Expects[${i}]: ${ez_test_check_expects[${i}]}"
                echo "${EZ_INDENT}Results[${i}]: ${ez_test_check_results[${i}]}"
                echo; error=1; break   
            fi
        done
    fi
    return "${error}"
}