function ez.url.decode { : "${*//+/ }"; echo -e "${_//%/\\x}"; }  # : is a builtin to expand arguments 
function ez.url.encode {
    local url_string; for url_string in "${@}"; do
        local i=0; for ((; i < ${#url_string}; i++)); do
            local character=${url_string:i:1}
            case "${character}" in
                [a-zA-Z0-9.~_-]) printf "${character}" ;;
                *) printf '%%%02X' "'$character"
            esac
        done
        echo
    done
}
