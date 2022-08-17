

function ezb_decimal_to_hex() {
	local decimal="${1}" zero_padding_length="${2}"
	[[ -z "${zero_padding_length}" ]] && zero_padding_length=2
    printf "%0${zero_padding_length}x\n" "${decimal}"
}