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
        100) echo "${1} - Continue" ;;
        101) echo "${1} - Switching Protocols" ;;
        102) echo "${1} - Processing" ;;
        103) echo "${1} - Early Hints" ;;
        # Successful Codes (2xx)
        200) echo "${1} - OK" ;;
        201) echo "${1} - Created" ;;
        202) echo "${1} - Accepted" ;;
        203) echo "${1} - Non-Authoritative Information" ;;
        204) echo "${1} - No Content" ;;
        205) echo "${1} - Reset Content" ;;
        206) echo "${1} - Partial Content" ;;
        207) echo "${1} - Multi-Status" ;;
        208) echo "${1} - Already Reported" ;;
        226) echo "${1} - IM Used" ;;
        # Redirection Codes (3xx)
        300) echo "${1} - Multiple Choices" ;;
        301) echo "${1} - Moved Permanently" ;;
        302) echo "${1} - Found" ;;
        303) echo "${1} - See Other" ;;
        304) echo "${1} - Not Modified" ;;
        305) echo "${1} - Use Proxy" ;;
        306) echo "${1} - Switch Proxy" ;;
        307) echo "${1} - Temporary Redirect" ;;
        308) echo "${1} - Permanent Redirect" ;;
        # Client Error Codes (4xx)
        400) echo "${1} - Bad Request" ;;
        401) echo "${1} - Unauthorized" ;;
        402) echo "${1} - Payment Required" ;;
        403) echo "${1} - Forbidden" ;;
        404) echo "${1} - Not Found" ;;
        405) echo "${1} - Method Not Allowed" ;;
        406) echo "${1} - Not Acceptable" ;;
        407) echo "${1} - Proxy Authentication Required" ;;
        408) echo "${1} - Request Timeout" ;;
        409) echo "${1} - Conflict" ;;
        410) echo "${1} - Gone" ;;
        411) echo "${1} - Length Required." ;;
        412) echo "${1} - Precondition Failed" ;;
        413) echo "${1} - Request Entity Too Large" ;;
        414) echo "${1} - Request-URI Too Long" ;;
        415) echo "${1} - Unsupported Media Type" ;;
        416) echo "${1} - Requested Range Not Satisfiable" ;;
        417) echo "${1} - Expectation Failed" ;;
        418) echo "${1} - I'm a teapot" ;;
        421) echo "${1} - Misdirected Request" ;;
        422) echo "${1} - Unprocessable Content" ;;
        423) echo "${1} - Locked" ;;
        424) echo "${1} - Failed Dependency" ;;
        425) echo "${1} - Too Early" ;;
        426) echo "${1} - Upgrade Required" ;;
        428) echo "${1} - Precondition Required" ;;
        429) echo "${1} - Too Many Requests" ;;
        431) echo "${1} - Request Header Fields Too Large" ;;
        451) echo "${1} - Unavailable For Legal Reasons" ;;
        # Server Error Codes (5xx)
        500) echo "${1} - Internal Server Error" ;;
        501) echo "${1} - Not Implemented" ;;
        502) echo "${1} - Bad Gateway" ;;
        503) echo "${1} - Service Unavailable" ;;
        504) echo "${1} - Gateway Timeout" ;;
        505) echo "${1} - HTTP Version Not Supported" ;;
        506) echo "${1} - Variant Also Negotiates" ;;
        507) echo "${1} - Insufficient Storage" ;;
        508) echo "${1} - Loop Detected" ;;
        510) echo "${1} - Not Extended" ;;
        511) echo "${1} - Network Authentication Required" ;;
        525) echo "${1} - SSL Handshake Failed" ;;
        *) ez.log.error "HTTP Code Not Found: ${1}"; return 1 ;;
    esac
}

