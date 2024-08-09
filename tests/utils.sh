source "${EZ_BASH_HOME}/src/core/basic.sh" || exit 1

function ez.test.check {
    local benchmarks=() results=() arg_list=("-e" "--benchmarks" "-r" "--results" "-s" "--subject") index benchmark result subject
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Compare Results with Benchmarks" \
        -a "-s|--subject" -t "String" -d "" -c "" -i "Check Subject" \
        -a "-b|--benchmarks" -t "List" -d "" -c "" -i "Benchmark Data List" \
        -a "-r|--results" -t "List" -d "" -c "" -i "Result Data List" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-s" | "--subject") shift; subject="${1}"; shift ;;
            "-b" | "--benchmarks") shift; while [[ -n "${1}" ]] && ez.excludes "${1}" "${arg_list[@]}"; do benchmarks+=("${1}"); shift; done ;;
            "-r" | "--results") shift; while [[ -n "${1}" ]] && ez.excludes "${1}" "${arg_list[@]}"; do results+=("${1}"); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    [[ -n "${FUNCNAME[1]}" ]] && echo "[${FUNCNAME[1]}] "; [[ -n "${subject}" ]] && echo "${subject}"
    if [[ "${#benchmarks[@]}" -ne "${#results[@]}" ]]; then
        echo "${EZ_INDENT}Benchmarks:"
        for benchmark in "${benchmarks[@]}"; do echo "${EZ_INDENT}${EZ_INDENT}${benchmark}"; done
        echo "${EZ_INDENT}Results:"
        for result in "${results[@]}"; do echo "${EZ_INDENT}${EZ_INDENT}${result}"; done
        echo; return 1
    fi
    for ((index=0; index < "${#benchmarks[@]}"; ++index)); do
        if [[ "${benchmarks[${index}]}" != "${results[${index}]}" ]]; then
            echo "${EZ_INDENT}Benchmarks:"
            for benchmark in "${benchmarks[@]}"; do echo "${EZ_INDENT}${EZ_INDENT}${benchmark}"; done
            echo "${EZ_INDENT}Results:"
            for result in "${results[@]}"; do echo "${EZ_INDENT}${EZ_INDENT}${result}"; done
            echo; return 1
        fi
    done
    echo "${EZ_INDENT}Passed!"; echo
}