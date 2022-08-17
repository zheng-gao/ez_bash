###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ezb_dependency_check "printf" "bc" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_decimal_to_base_x() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-d" --long "--decimal" --required --info "Decimal Number" &&
        ezb_arg_set --short "-b" --long "--base" --default "2" --choices "2" "8" "16" --info "Base x" &&
        ezb_arg_set --short "-p" --long "--padding" --default "2" --info "Zero Padding Size" || return 1
    fi
    ezb_function_usage "${@}" && return
    local decimal && decimal="$(ezb_arg_get --short "-d" --long "--decimal" --arguments "${@}")" &&
    local base && base="$(ezb_arg_get --short "-b" --long "--base" --arguments "${@}")" &&
    local padding && padding="$(ezb_arg_get --short "-p" --long "--padding" --arguments "${@}")" || return 1
    if [[ "${base}" == "16" ]]; then
    	printf "%0${padding}x\n" "${decimal}"
    else
        printf "%0${padding}d\n" $(bc <<< "obase=${base};${decimal}")
    fi
}
