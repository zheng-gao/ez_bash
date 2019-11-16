function ezb_url_encode() {
    local url_string="${@}"
    for (( i = 0; i < ${#url_string}; i++ )); do
        local character=${url_string:i:1}
        case "${character}" in
            [a-zA-Z0-9.~_-]) printf "${character}" ;;
            *) printf '%%%02X' "'$character"
        esac
    done
    echo
}
