###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_calculate {
    if ez_function_unregistered; then
        ez_arg_set --short "-e" --long "--expression" --required &&
        ez_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ez_function_usage "${@}" && return
    local expression && expression="$(ez_arg_get --short "-e" --long "--expression" --arguments "${@}")" &&
    local scale && scale="$(ez_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    # bc scale does not work for mode %
    local result=$(bc -l <<< "scale=${scale}; ${expression}")
    if [[ "${result:0:1}" = "." ]]; then
        result="0${result}"
    elif [[ "${result:0:2}" = "-." ]]; then
        result="-0${result:1}"
    fi
    echo "${result}"
}

function ez_floor {
    local parts; ez.string.split "parts" "." "${1}"
    local result="${parts[0]}"; if [[ -z "${result}" ]] || [[ "${result}" = "-" ]]; then result+="0"; fi
    [[ -n "${parts[1]}" ]] && [[ "${parts[1]}" -ne 0 ]] && [[ "${1:0:1}" = "-" ]] && ((--result))
    echo "${result}"
}

function ez_ceiling {
    local parts; ez.string.split "parts" "." "${1}"
    local result="${parts[0]}"; if [[ -z "${result}" ]] || [[ "${result}" = "-" ]]; then result+="0"; fi
    [[ -n "${parts[1]}" ]] && [[ "${parts[1]}" -ne 0 ]] && [[ "${1:0:1}" != "-" ]] && ((++result))
    echo "${result}"
}

function ez_convert_decimal_to_base_x {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--decimal" --required --info "Decimal Number" &&
        ez_arg_set --short "-b" --long "--base" --required --default "2" --choices "2" "8" "16" --info "Base x" &&
        ez_arg_set --short "-p" --long "--padding" --default "2" --info "Total length for padding if not fill" || return 1
    fi
    ez_function_usage "${@}" && return
    local decimal && decimal="$(ez_arg_get --short "-d" --long "--decimal" --arguments "${@}")" &&
    local base && base="$(ez_arg_get --short "-b" --long "--base" --arguments "${@}")" &&
    local padding && padding="$(ez_arg_get --short "-p" --long "--padding" --arguments "${@}")" || return 1
    if [[ "${base}" -eq "16" ]]; then printf "%0${padding}x\n" "${decimal}"
    elif [[ "${base}" -eq "8" ]]; then printf "%0${padding}o\n" "${decimal}"
    else printf "%0${padding}d\n" $(bc <<< "obase=${base};${decimal}")
    fi
}

function ez_convert_base_x_to_decimal {
    if ez_function_unregistered; then
        ez_arg_set --short "-v" --long "--value" --required --info "Base X value" &&
        ez_arg_set --short "-b" --long "--base" --required --default "2" --choices "2" "8" "16" --info "Base x" || return 1
    fi
    ez_function_usage "${@}" && return
    local value && value="$(ez_arg_get --short "-v" --long "--value" --arguments "${@}")" &&
    local base && base="$(ez_arg_get --short "-b" --long "--base" --arguments "${@}")" || return 1
    if [[ "${base}" -eq "16" ]]; then
        [[ "${value:0:2}" != "0x" ]] && value="0x${value}"
        printf "%d\n" "${value}"
    elif [[ "${base}" -eq "8" ]]; then
        [[ "${value:0:1}" != "0" ]] && value="0${value}"
        printf "%d\n" "${value}"
    else
        bc <<< "ibase=${base};${value}"
    fi
}


function ez_min {
    if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    local min=2147483647 data; for data in "${@}"; do
        if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi
    done
    echo "${min}"
}

function ez_max {
    if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    local max=-2147483647 data; for data in "${@}"; do
        if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi
    done
    echo "${max}"
}

function ez_sum {
    if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    local sum=0 data; for data in "${@}"; do
        sum=$(ez_calculate --expression "${sum} + ${data}")
    done
    echo "${sum}"
}

function ez_average {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--data" --type "List" --required &&
        ez_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ez_function_usage "${@}" && return
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_average_data_list; ez_function_get_list "ez_average_data_list" "${data}"
    if [[ "${#ez_average_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    ez_calculate --expression "$(ez_sum ${ez_average_data_list[@]}) / ${#ez_average_data_list[@]}" --scale "${scale}"
}

function ez_variance {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--data" --type "List" --required &&
        ez_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ez_function_usage "${@}" && return
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_variance_data_list; ez_function_get_list "ez_variance_data_list" "${data}"
    if [[ "${#ez_variance_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    local average=$(ez_average --data "${ez_variance_data_list[@]}")
    local variance=0 data; for data in "${ez_variance_data_list[@]}"; do
        variance=$(ez_calculate --expression "${variance} + (${data} - ${average}) ^ 2")
    done
    ez_calculate --expression "${variance} / (${#ez_variance_data_list[@]} - 1)" --scale "${scale}"
}

function ez_std_deviation {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--data" --type "List" --required &&
        ez_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ez_function_usage "${@}" && return
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_std_deviation_data_list; ez_function_get_list "ez_std_deviation_data_list" "${data}"
    if [[ "${#ez_std_deviation_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    ez_calculate --expression "sqrt($(ez_variance --data ${ez_std_deviation_data_list[@]}))" --scale "${scale}"
}

function ez_percentile {
    if ez_function_unregistered; then
        ez_arg_set --short "-d" --long "--data" --type "List" --required &&
        ez_arg_set --short "-p" --long "--percentile" --required --default 50 &&
        ez_arg_set --short "-m" --long "--method" --required --default "Linear" --choices "Linear" "Lower" "Higher" "Midpoint" "Nearest" &&
        ez_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ez_function_usage "${@}" && return
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" &&
    local percentile && percentile="$(ez_arg_get --short "-p" --long "--percentile" --arguments "${@}")" &&
    local method && method="$(ez_arg_get --short "-m" --long "--method" --arguments "${@}")" &&
    local scale && scale="$(ez_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_percentile_data_list; ez_function_get_list "ez_percentile_data_list" "${data}"
    if [[ "${#ez_percentile_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    if (( $(bc -l <<< "${percentile} < 0") )) || (( $(bc -l <<< "${percentile} > 100") )); then
        ez.log.error "Invalid percentile: ${percentile}"; return 1
    fi
    local data_set=($(ez_sort --data "${ez_percentile_data_list[@]}" --number))
    if [[ "${percentile}" -eq 0 ]]; then
        echo "${data_set[0]}"
    elif [[ "${percentile}" -eq 100 ]]; then
        echo "${data_set[-1]}"
    else
        local ith=$(ez_calculate --expression "(${#data_set[@]} - 1) * ${percentile} / 100" --scale "${scale}")
        local ith_floor="$(ez_floor ${ith})" ith_ceiling="$(ez_ceiling ${ith})"
        local ith_fractional=$(ez_calculate --expression "${ith} - ${ith_floor}" --scale "${scale}")
        if [[ "${ith_floor}" != "${ith_ceiling}" ]]; then
            local floor_data="${data_set[${ith_floor}]}" ceiling_data="${data_set[${ith_ceiling}]}"
            if [[ "${method}" = "Linear" ]]; then
                ez_calculate --expression "${floor_data} + ${ith_fractional} * (${ceiling_data} - ${floor_data})" --scale "${scale}"
            elif [[ "${method}" = "Lower" ]]; then
                echo "${floor_data}"
            elif [[ "${method}" = "Higher" ]]; then
                echo "${ceiling_data}"
            elif [[ "${method}" = "Midpoint" ]]; then
                ez_calculate --expression "(${ceiling_data} + ${floor_data}) / 2" --scale "${scale}"
            elif [[ "${method}" = "Nearest" ]]; then
                if (( $(bc -l <<< "${ith_fractional} <= 0.5") )); then echo "${floor_data}"; else echo "${ceiling_data}"; fi
            fi
        else
            echo "${data_set[${ith_floor}]}"
        fi
    fi
}

function ez_random_int {
    if ez_function_unregistered; then
        ez_arg_set --short "-l" --long "--lower-bound" --required --default 0 --info "Inclusive Lower Bound" &&
        ez_arg_set --short "-u" --long "--upper-bound" --required --info "Exclusive Upper Bound" || return 1
    fi
    ez_function_usage "${@}" && return
    local lower_bound && lower_bound="$(ez_arg_get --short "-l" --long "--lower-bound" --arguments "${@}")" &&
    local upper_bound && upper_bound="$(ez_arg_get --short "-u" --long "--upper-bound" --arguments "${@}")" || return 1
    [ "${lower_bound}" -gt "${upper_bound}" ] && return 2
    # Use $RANDOM as seed, which is an internal Bash function that returns a pseudo-random integer in the range [0, 32767]
    local seed="${RANDOM}"
    echo $(( (seed * 214013 + 2531011) % (upper_bound - lower_bound) + lower_bound ))
}