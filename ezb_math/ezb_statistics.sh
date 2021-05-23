function ezb_min() {
    [[ "${#}" -eq 0 ]] && return 1
    local min=2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi
    done
    echo "${min}"
}

function ezb_max() {
    [[ "${#}" -eq 0 ]] && return 1
    local max=-2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi
    done
    echo "${max}"
}

function ezb_sum() {
    [[ "${#}" -eq 0 ]] && return 1
    local sum=0; local data=""
    for data in "${@}"; do
        sum=$(ezb_math "${sum} + ${data}")
    done
    echo "${sum}"
}

function ezb_average() {
    [[ "${#}" -eq 0 ]] && return 1
    ezb_math "$(ezb_sum ${@}) / ${#}"
}

function ezb_variance() {
    [[ "${#}" -eq 0 ]] && return 1
    local average=$(ezb_average ${@}); local variance=0; local data=""
    for data in "${@}"; do
        variance=$(ezb_math "${variance} + (${data} - ${average}) * (${data} - ${average})")
    done
    ezb_math "sqrt(${variance})"
}

function ezb_percentile() {
    # [P50 Example] ezb_percentile 50 1 2 3 4 5
    [[ "${#}" -eq 0 ]] && return 1
    local percentile="${1}"
    [[ "${percentile}" -ge 100 ]] && return 1
    [[ "${percentile}" -le 0 ]] && return 1
    local data_set=($(for data in "${@:2}"; do echo "${data}"; done | sort -n))
    local index=$(ezb_math "${#data_set[@]} * ${percentile} / 100")
    local index_floor="$(ezb_floor ${index})"
    local index_ceiling="$(ezb_ceiling ${index})"
    if [[ "${index_floor}" -eq "${index_ceiling}" ]]; then
        echo "$(ezb_average ${data_set[$((index_floor - 1))]} ${data_set[${index_floor}]})"
    else
        echo "${data_set[${index_floor}]}"
    fi
}




