###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "bc" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_calculate() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-e" --long "--expression" --required &&
        ezb_arg_set --short "-s" --long "--scale" --required --default 6 || return 1
    fi
    ezb_function_usage "${@}" && return
    local expression && expression="$(ezb_arg_get --short "-e" --long "--expression" --arguments "${@}")" &&
    local scale && scale="$(ezb_arg_get --short "-s" --long "--scale" --arguments "${@}")" || return 1
    # bc scale does not work for mode %
    local result=$(bc -l <<< "scale=${scale}; ${expression}")
    if [[ "${result:0:1}" = "." ]]; then
        result="0${result}"
    elif [[ "${result:0:2}" = "-." ]]; then
        result="-0${result:1}"
    fi
    echo "${result}"
}

function ezb_floor() {
    local parts; ezb_split "parts" "." "${1}"
    local result="${parts[0]}"; if [[ -z "${result}" ]] || [[ "${result}" = "-" ]]; then result+="0"; fi
    [[ -n "${parts[1]}" ]] && [[ "${parts[1]}" -ne 0 ]] && [[ "${1:0:1}" = "-" ]] && ((--result))
    echo "${result}"
}

function ezb_ceiling() {
    local parts; ezb_split "parts" "." "${1}"
    local result="${parts[0]}"; if [[ -z "${result}" ]] || [[ "${result}" = "-" ]]; then result+="0"; fi
    [[ -n "${parts[1]}" ]] && [[ "${parts[1]}" -ne 0 ]] && [[ "${1:0:1}" != "-" ]] && ((++result))
    echo "${result}"
}
