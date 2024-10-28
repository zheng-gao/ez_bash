###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "netstat" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.netstat {
    if [[ "$(uname -s)" = "Darwin" ]]; then
        if [[ "${1}" = "sudo" ]]; then
            sudo netstat -p "UDP" -p "TCP" -anv | grep -i "listen\|Local Address"
        else
            netstat -p "UDP" -p "TCP" -anv | grep -i "listen\|Local Address"
        fi
    else  # Linux
        if [[ "${1}" = "sudo" ]]; then
            sudo netstat -tulpn | grep -i "listen\|Local Address"
        else
            netstat -tulpn | grep -i "listen\|Local Address"
        fi
    fi
}

function ez.http.code {
    case "${1}" in
        # Informational Codes (1xx)
        100) echo "Continue" ;;
        101) echo "Switching Protocols" ;;
        # Successful Codes (2xx)
        200) echo "OK" ;;
        201) echo "Created" ;;
        202) echo "Accepted" ;;
        203) echo "Non-Authoritative Information" ;;
        204) echo "No Content" ;;
        205) echo "Reset Content" ;;
        206) echo "Partial Content" ;;
        # Redirection Codes (3xx)
        300) echo "Multiple Choices" ;;
        301) echo "Moved Permanently" ;;
        302) echo "Found" ;;
        303) echo "See Other" ;;
        304) echo "Not Modified" ;;
        305) echo "Use Proxy" ;;
        306) echo "Switch Proxy" ;;
        307) echo "Temporary Redirect" ;;
        # Client Error Codes (4xx)
        400) echo "Bad Request" ;;
        401) echo "Unauthorized" ;;
        402) echo "Payment Required" ;;
        403) echo "Forbidden" ;;
        404) echo "Not Found" ;;
        405) echo "Method Not Allowed" ;;
        406) echo "Not Acceptable" ;;
        407) echo "Proxy Authentication Required" ;;
        408) echo "Request Timeout" ;;
        409) echo "Conflict" ;;
        410) echo "Gone" ;;
        411) echo "Length Required." ;;
        412) echo "Precondition Failed" ;;
        413) echo "Request Entity Too Large" ;;
        414) echo "Request-URI Too Long" ;;
        415) echo "Unsupported Media Type" ;;
        416) echo "Requested Range Not Satisfiable" ;;
        417) echo "Expectation Failed" ;;
        # Server Error Codes (5xx)
        500) echo "Internal Server Error" ;;
        501) echo "Not Implemented" ;;
        502) echo "Bad Gateway" ;;
        503) echo "Service Unavailable" ;;
        504) echo "Gateway Timeout" ;;
        505) echo "HTTP Version Not Supported" ;;
        525) echo "SSL Handshake Failed" ;;
        *) ez.log.error "Not Implemented: ${1}"; return 1 ;;
    esac
}