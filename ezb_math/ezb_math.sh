###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "bc" || return 1

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_MATH_SCALE=6

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_arithmetic() {
    # bc scale does not work for mode %
    bc <<< "scale=${EZB_MATH_SCALE}; ${@}"
}

function ezb_floor() {
    local parts; ezb_split "parts" "." "${1}"
    local result="${parts[0]}"; if [[ -z "${result}" ]] || [[ "${result}" = "-" ]]; then result+="0"; fi
    [[ -n "${parts[1]}" ]] && [[ "${parts[1]}" -ne 0 ]] && [[ "${1:0:1}" = "-" ]] && ((--result))
    echo "${result}"
}

function ezb_ceiling() {
	# 1.00 -> 1
	# 1.01 -> 2
	local integer_part=$(cut -d "." -f "1" <<< "${1}")
	local decimal_part=$(cut -d "." -f "2" <<< "${1}")
    if [[ "${decimal_part}" -gt 0 ]]; then
    	echo "$(( integer_part + 1 ))"
    else
    	echo "${integer_part}"
    fi
}
