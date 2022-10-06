function ezb_min() {
    if [[ "${#}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    local min=2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi
    done
    echo "${min}"
}

function ezb_max() {
    if [[ "${#}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    local max=-2147483647; local data=""
    for data in "${@}"; do
        if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi
    done
    echo "${max}"
}

function ezb_sum() {
    if [[ "${#}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    local sum=0; local data=""
    for data in "${@}"; do
        sum=$(ezb_calculate --expression "${sum} + ${data}")
    done
    echo "${sum}"
}

function ezb_average() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--data" --type "List" --required &&
        ezb_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ezb_function_usage "${@}" && return
    local data && data="$(ezb_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ezb_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ezb_average_data_list; ezb_function_get_list "ezb_average_data_list" "${data}"
    if [[ "${#ezb_average_data_list[@]}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    ezb_calculate --expression "$(ezb_sum ${ezb_average_data_list[@]}) / ${#ezb_average_data_list[@]}" --scale "${scale}"
}

function ezb_variance() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--data" --type "List" --required &&
        ezb_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ezb_function_usage "${@}" && return
    local data && data="$(ezb_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ezb_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ezb_variance_data_list; ezb_function_get_list "ezb_variance_data_list" "${data}"
    if [[ "${#ezb_variance_data_list[@]}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    local average=$(ezb_average --data "${ezb_variance_data_list[@]}")
    local variance=0; local data=""
    for data in "${ezb_variance_data_list[@]}"; do
        variance=$(ezb_calculate --expression "${variance} + (${data} - ${average}) ^ 2")
    done
    ezb_calculate --expression "${variance} / (${#ezb_variance_data_list[@]} - 1)" --scale "${scale}"
}

function ezb_std_deviation() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--data" --type "List" --required &&
        ezb_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ezb_function_usage "${@}" && return
    local data && data="$(ezb_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ezb_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ezb_std_deviation_data_list; ezb_function_get_list "ezb_std_deviation_data_list" "${data}"
    if [[ "${#ezb_std_deviation_data_list[@]}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    ezb_calculate --expression "sqrt($(ezb_variance --data ${ezb_std_deviation_data_list[@]}))" --scale "${scale}"
}

function ezb_percentile() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--data" --type "List" --required &&
        ezb_arg_set --short "-p" --long "--percentile" --required --default 50 &&
        ezb_arg_set --short "-m" --long "--method" --required --default "Linear" --choices "Linear" "Lower" "Higher" "Midpoint" "Nearest" &&
        ezb_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ezb_function_usage "${@}" && return
    local data && data="$(ezb_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local percentile && percentile="$(ezb_arg_get --short "-p" --long "--percentile" --arguments "${@}")" &&
    local method && method="$(ezb_arg_get --short "-m" --long "--method" --arguments "${@}")" &&
    local scale && scale="$(ezb_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ezb_percentile_data_list; ezb_function_get_list "ezb_percentile_data_list" "${data}"
    if [[ "${#ezb_percentile_data_list[@]}" -eq 0 ]]; then ezb_log_error "No data found"; return 1; fi
    if (( $(bc -l <<< "${percentile} < 0") )) || (( $(bc -l <<< "${percentile} > 100") )); then
        ezb_log_error "Invalid percentile: ${percentile}"; return 1
    fi
    local data_set=($(ezb_sort --data "${ezb_percentile_data_list[@]}" --number))
    if [[ "${percentile}" -eq 0 ]]; then
        echo "${data_set[0]}"
    elif [[ "${percentile}" -eq 100 ]]; then
        echo "${data_set[-1]}"
    else
        local ith=$(ezb_calculate --expression "(${#data_set[@]} - 1) * ${percentile} / 100" --scale "${scale}")
        local ith_floor="$(ezb_floor ${ith})" ith_ceiling="$(ezb_ceiling ${ith})"
        local ith_fractional=$(ezb_calculate --expression "${ith} - ${ith_floor}" --scale "${scale}")
        if [[ "${ith_floor}" != "${ith_ceiling}" ]]; then
            local floor_data="${data_set[${ith_floor}]}" ceiling_data="${data_set[${ith_ceiling}]}"
            if [[ "${method}" = "Linear" ]]; then
                ezb_calculate --expression "${floor_data} + ${ith_fractional} * (${ceiling_data} - ${floor_data})" --scale "${scale}"
            elif [[ "${method}" = "Lower" ]]; then
                echo "${floor_data}"
            elif [[ "${method}" = "Higher" ]]; then
                echo "${ceiling_data}"
            elif [[ "${method}" = "Midpoint" ]]; then
                ezb_calculate --expression "(${ceiling_data} + ${floor_data}) / 2" --scale "${scale}"
            elif [[ "${method}" = "Nearest" ]]; then
                if (( $(bc -l <<< "${ith_fractional} <= 0.5") )); then echo "${floor_data}"; else echo "${ceiling_data}"; fi
            fi
        else
            echo "${data_set[${ith_floor}]}"
        fi
    fi
}




