function ezb_min() {
    [[ "${#}" -eq 0 ]] && return
    local min=2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi
    done
    echo "${min}"
}

function ezb_max() {
    [[ "${#}" -eq 0 ]] && return
    local max=-2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi
    done
    echo "${max}"
}

function ezb_sum() {
    [[ "${#}" -eq 0 ]] && return
    local sum=0; local data=""
    for data in "${@}"; do
        sum=$(ezb_math "${sum} + ${data}")
    done
    echo "${sum}"
}

function ezb_average() {
    [[ "${#}" -eq 0 ]] && return
    ezb_math "$(ezb_sum ${@}) / ${#}"
}

function ezb_variance() {
    [[ "${#}" -eq 0 ]] && return
    local average=$(ezb_average ${@}); local variance=0; local data=""
    for data in "${@}"; do
        variance=$(ezb_math "${variance} + (${data} - ${average}) * (${data} - ${average})")
    done
    ezb_math "sqrt(${variance})"
}






