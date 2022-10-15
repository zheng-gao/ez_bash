function ezb_expect_result() {
	local expect="${1}" result="${2}"
    if [[ "${expect}" != "${result}" ]]; then
        echo "[${FUNCNAME[1]}] Expect: \"${expect}\""
        echo "[${FUNCNAME[1]}] Result: \"${result}\""
        return 1
    fi
}