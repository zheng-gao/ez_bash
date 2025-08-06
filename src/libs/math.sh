###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_INT_MAX=2147483647
EZ_INT_MIN=-2147483647

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.math.floor {
    local ez_math_floor_parts; ez.split "ez_math_floor_parts" "." "${1}"
    local result="${ez_math_floor_parts[0]}"; if [[ -z "${result}" || "${result}" = "-" ]]; then result+="0"; fi
    if [[ -n "${ez_math_floor_parts[1]}" && "${ez_math_floor_parts[1]}" -ne 0 && "${1:0:1}" = "-" ]]; then ((--result)); fi; echo "${result}"
}
function ez.math.ceiling {
    local ez_math_ceiling_parts; ez.split "ez_math_ceiling_parts" "." "${1}"
    local result="${ez_math_ceiling_parts[0]}"; if [[ -z "${result}" || "${result}" = "-" ]]; then result+="0"; fi
    if [[ -n "${ez_math_ceiling_parts[1]}" && "${ez_math_ceiling_parts[1]}" -ne 0 && "${1:0:1}" != "-" ]]; then ((++result)); fi; echo "${result}"
}
function ez.math.min {
    local min="${EZ_INT_MAX}" data; if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    for data in "${@}"; do if (( $(bc -l <<< "${data} < ${min}") )); then min="${data}"; fi; done; echo "${min}"
}
function ez.math.max {
    local max="${EZ_INT_MIN}" data; if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    for data in "${@}"; do if (( $(bc -l <<< "${data} > ${max}") )); then max="${data}"; fi; done; echo "${max}"
}
function ez.math.sum {
    local sum=0 data; if [[ "${#}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    for data in "${@}"; do sum=$(ez.math.calculate --expression "${sum} + ${data}"); done; echo "${sum}"
}
function ez.math.average {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--data" --type "List" --required &&
        ez.argument.set --short "-s" --long "--scale" --required --default 6 --info "Number of digits after the dot" || return 1
    fi; ez.function.help "${@}" || return 0
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez.argument.get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_math_average_data_list; ez.function.arguments.get_list "ez_math_average_data_list" "${data}"
    if [[ "${#ez_math_average_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    ez.math.calculate --expression "$(ez.math.sum ${ez_math_average_data_list[@]}) / ${#ez_math_average_data_list[@]}" --scale "${scale}"
}
function ez.math.variance {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--data" --type "List" --required &&
        ez.argument.set --short "-s" --long "--scale" --required --default 6 || return 1
    fi; ez.function.help "${@}" || return 0
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez.argument.get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_math_variance_data_list; ez.function.arguments.get_list "ez_math_variance_data_list" "${data}"
    if [[ "${#ez_math_variance_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    local average=$(ez.math.average --data "${ez_math_variance_data_list[@]}" --scale "${scale}") variance=0 data
    for data in "${ez_math_variance_data_list[@]}"; do variance=$(ez.math.calculate --expression "${variance} + (${data} - ${average}) ^ 2" --scale "${scale}"); done
    ez.math.calculate --expression "${variance} / (${#ez_math_variance_data_list[@]} - 1)" --scale "${scale}"
}
function ez.math.std_deviation {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--data" --type "List" --required &&
        ez.argument.set --short "-s" --long "--scale" --required --default 6 || return 1
    fi; ez.function.help "${@}" || return 0
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local scale && scale="$(ez.argument.get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez_math_std_deviation_data_list; ez.function.arguments.get_list "ez_math_std_deviation_data_list" "${data}"
    if [[ "${#ez_math_std_deviation_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    ez.math.calculate --expression "sqrt($(ez.math.variance --data "${ez_math_std_deviation_data_list[@]}" --scale "${scale}"))" --scale "${scale}"
}
function ez.math.calculate {
    if ez.function.unregistered; then
        ez.argument.set --short "-e" --long "--expression" --required &&
        ez.argument.set --short "-s" --long "--scale" --required --default 6 || return 1
    fi; ez.function.help "${@}" || return 0
    local expression && expression="$(ez.argument.get --short "-e" --long "--expression" --arguments "${@}")" &&
    local scale && scale="$(ez.argument.get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local result=$(bc -l <<< "scale=${scale}; ${expression}")  # bc scale does not work for mode %
    if [[ "${result:0:1}" = "." ]]; then result="0${result}"; elif [[ "${result:0:2}" = "-." ]]; then result="-0${result:1}"; fi; echo "${result}"
}

function ez.math.decimal.to_base_x {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--decimal" --required --info "Decimal Number" &&
        ez.argument.set --short "-b" --long "--base" --required --default "2" --choices "2" "8" "16" --info "Base x" &&
        ez.argument.set --short "-p" --long "--padding" --default "2" --info "Total length for padding if not fill" || return 1
    fi; ez.function.help "${@}" || return 0
    local decimal && decimal="$(ez.argument.get --short "-d" --long "--decimal" --arguments "${@}")" &&
    local base && base="$(ez.argument.get --short "-b" --long "--base" --arguments "${@}")" &&
    local padding && padding="$(ez.argument.get --short "-p" --long "--padding" --arguments "${@}")" || return 1
    if [[ "${base}" -eq "16" ]]; then printf "%0${padding}x\n" "${decimal}"
    elif [[ "${base}" -eq "8" ]]; then printf "%0${padding}o\n" "${decimal}"
    else printf "%0${padding}d\n" $(bc <<< "obase=${base};${decimal}")
    fi
}

function ez.math.decimal.from_base_x {
    if ez.function.unregistered; then
        ez.argument.set --short "-v" --long "--value" --required --info "Base X value" &&
        ez.argument.set --short "-b" --long "--base" --required --default "2" --choices "2" "8" "16" --info "Base x" || return 1
    fi; ez.function.help "${@}" || return 0
    local value && value="$(ez.argument.get --short "-v" --long "--value" --arguments "${@}")" &&
    local base && base="$(ez.argument.get --short "-b" --long "--base" --arguments "${@}")" || return 1
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

function ez.math.percentile {
    if ez.function.unregistered; then
        ez.argument.set --short "-d" --long "--data" --type "List" --required &&
        ez.argument.set --short "-p" --long "--percentile" --required --default 50 &&
        ez.argument.set --short "-m" --long "--method" --required --default "Linear" --choices "Linear" "Lower" "Higher" "Midpoint" "Nearest" &&
        ez.argument.set --short "-s" --long "--scale" --required --default 6 || return 1
    fi; ez.function.help "${@}" || return 0
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" &&
    local percentile && percentile="$(ez.argument.get --short "-p" --long "--percentile" --arguments "${@}")" &&
    local method && method="$(ez.argument.get --short "-m" --long "--method" --arguments "${@}")" &&
    local scale && scale="$(ez.argument.get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    local ez.math.percentile_data_list; ez.function.arguments.get_list "ez.math.percentile_data_list" "${data}"
    if [[ "${#ez.math.percentile_data_list[@]}" -eq 0 ]]; then ez.log.error "No data found"; return 1; fi
    if (( $(bc -l <<< "${percentile} < 0") )) || (( $(bc -l <<< "${percentile} > 100") )); then
        ez.log.error "Invalid percentile: ${percentile}"; return 1
    fi
    local data_set=($(ez.sort --data "${ez.math.percentile_data_list[@]}" --number))
    if [[ "${percentile}" -eq 0 ]]; then
        echo "${data_set[0]}"
    elif [[ "${percentile}" -eq 100 ]]; then
        echo "${data_set[-1]}"
    else
        local ith=$(ez.math.calculate --expression "(${#data_set[@]} - 1) * ${percentile} / 100" --scale "${scale}")
        local ith_floor="$(ez.math.floor ${ith})" ith_ceiling="$(ez.math.ceiling ${ith})"
        local ith_fractional=$(ez.math.calculate --expression "${ith} - ${ith_floor}" --scale "${scale}")
        if [[ "${ith_floor}" != "${ith_ceiling}" ]]; then
            local floor_data="${data_set[${ith_floor}]}" ceiling_data="${data_set[${ith_ceiling}]}"
            if [[ "${method}" = "Linear" ]]; then
                ez.math.calculate --expression "${floor_data} + ${ith_fractional} * (${ceiling_data} - ${floor_data})" --scale "${scale}"
            elif [[ "${method}" = "Lower" ]]; then
                echo "${floor_data}"
            elif [[ "${method}" = "Higher" ]]; then
                echo "${ceiling_data}"
            elif [[ "${method}" = "Midpoint" ]]; then
                ez.math.calculate --expression "(${ceiling_data} + ${floor_data}) / 2" --scale "${scale}"
            elif [[ "${method}" = "Nearest" ]]; then
                if (( $(bc -l <<< "${ith_fractional} <= 0.5") )); then echo "${floor_data}"; else echo "${ceiling_data}"; fi
            fi
        else
            echo "${data_set[${ith_floor}]}"
        fi
    fi
}

