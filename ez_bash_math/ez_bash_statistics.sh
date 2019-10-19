###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_min() {
    [[ "${#}" -eq 0 ]] && return
    local min=2147483647
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi
    done
    echo "${min}"
}

function ez_max() {
    [[ "${#}" -eq 0 ]] && return
    local max=-2147483647
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi
    done
    echo "${max}"
}

function ez_sum() {
    [[ "${#}" -eq 0 ]] && return
    local sum=0
    for data in "${@}"; do
        sum=$(ez_math "${sum} + ${data}")
    done
    echo "${sum}"
}

function ez_average() {
    [[ "${#}" -eq 0 ]] && return
    ez_math "$(ez_sum ${@}) / ${#}"
}

function ez_variance() {
    [[ "${#}" -eq 0 ]] && return
    local average=$(ez_average ${@}); local variance=0
    for data in "${@}"; do
        variance=$(ez_math "${variance} + (${data} - ${average}) * (${data} - ${average})")
    done
    ez_math "sqrt(${variance})"
}






