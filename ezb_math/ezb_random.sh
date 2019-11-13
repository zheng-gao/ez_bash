function ezb_random_int() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-l" --long "--lower-bound" --default 0 --info "Inclusive Lower Bound" &&
        ezb_set_arg --short "-u" --long "--upper-bound" --required --info "Exclusive Upper Bound" || return 1
    fi
    ezb_function_usage "${@}" && return
    local lower_bound; lower_bound="$(ezb_get_arg --short "-l" --long "--lower-bound" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local upper_bound; upper_bound="$(ezb_get_arg --short "-u" --long "--upper-bound" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    [ "${lower_bound}" -gt "${upper_bound}" ] && return 2
    # Use $RANDOM as seed, which is an internal Bash function that returns a pseudo-random integer in the range [0, 32767]
    echo $(( ("${RANDOM}" * 214013 + 2531011) % ("${upper_bound}" - "${lower_bound}") + "${lower_bound}" ))
}
