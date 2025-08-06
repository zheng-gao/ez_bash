###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.random.int {
    if ez.function.unregistered; then
        ez.argument.set --short "-l" --long "--lower-bound" --required --default 0 --info "Inclusive Lower Bound" &&
        ez.argument.set --short "-u" --long "--upper-bound" --required --info "Exclusive Upper Bound" || return 1
    fi; ez.function.help "${@}" || return 0
    local lower_bound && lower_bound="$(ez.argument.get --short "-l" --long "--lower-bound" --arguments "${@}")" &&
    local upper_bound && upper_bound="$(ez.argument.get --short "-u" --long "--upper-bound" --arguments "${@}")" || return 1
    [ "${lower_bound}" -gt "${upper_bound}" ] && return 2
    # Use $RANDOM as seed, which is an internal Bash function that returns a pseudo-random integer in the range [0, 32767]
    local seed="${RANDOM}"; echo $(( (seed * 214013 + 2531011) % (upper_bound - lower_bound) + lower_bound ))
}

function ez.random.string {
    if ez.function.unregistered; then
        ez.argument.set --short "-l" --long "--length" --required --default 64 --info "Length of the random string" &&
        ez.argument.set --short "-c" --long "--character-sets" --type "List" --required --default "A-Z" "a-z" "0-9" --choices "A-Z" "a-z" "0-9" "non-alphanumeric" --info "Character Set Names" || return 1
    fi; ez.function.help "${@}" --run-with-no-arguments || return 0
    local length && length="$(ez.argument.get --short "-l" --long "--length" --arguments "${@}")" &&
    local character_sets && ez.function.arguments.get_list "character_sets" "$(ez.argument.get --short "-c" --long "--character-sets" --arguments "${@}")" || return 1
    local characters_all set_name random_index output_index=0 output=""
    declare -A CHARACTER_SET=(
        ["A-Z"]="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        ["a-z"]="abcdefghijklmnopqrstuvwxyz"
        ["0-9"]="0123456789"
        ["non-alphanumeric"]=" !?@#$%&*()<>[]{}+-*/=~^_\|.,;:"
    )
    for set_name in "${character_sets[@]}"; do characters_all+="${CHARACTER_SET[${set_name}]}"; done
    for ((; output_index < "${length}"; ++output_index)); do
        random_index="$(ez.random.int --lower-bound 0 --upper-bound "${#characters_all}")"
        output+="${characters_all:${random_index}:1}"
    done
    echo "${output}"
}