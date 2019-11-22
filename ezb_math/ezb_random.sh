function ezb_random_int() {
    if ezb_function_unregistered; then
        ezb_arg_set --short "-l" --long "--lower-bound" --default 0 --info "Inclusive Lower Bound" &&
        ezb_arg_set --short "-u" --long "--upper-bound" --required --info "Exclusive Upper Bound" || return 1
    fi
    ezb_function_usage "${@}" && return
    local lower_bound && lower_bound="$(ezb_arg_get --short "-l" --long "--lower-bound" --arguments "${@}")" &&
    local upper_bound && upper_bound="$(ezb_arg_get --short "-u" --long "--upper-bound" --arguments "${@}")" || return 1
    [ "${lower_bound}" -gt "${upper_bound}" ] && return 2
    # Use $RANDOM as seed, which is an internal Bash function that returns a pseudo-random integer in the range [0, 32767]
    local seed="${RANDOM}"
    echo $(( (seed * 214013 + 2531011) % (upper_bound - lower_bound) + lower_bound ))
}
