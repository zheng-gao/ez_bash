function ezb_url_encode() {
    local url_string="${@}"
    local i=0; for ((; i < ${#url_string}; i++)); do
        local character=${url_string:i:1}
        case "${character}" in
            [a-zA-Z0-9.~_-]) printf "${character}" ;;
            *) printf '%%%02X' "'$character"
        esac
    done
    echo
}

# : is a builtin to expand arguments 
function ezb_url_decode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
