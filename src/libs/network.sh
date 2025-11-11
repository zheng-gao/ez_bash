###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "netstat" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
declare -gA EZ_HTTP_CODES=(
    # Informational Codes (1xx)
    [100]="Continue"
    [101]="Switching Protocols"
    [102]="Processing"
    [103]="Early Hints"
    # Successful Codes (2xx)
    [200]="OK"
    [201]="Created"
    [202]="Accepted"
    [203]="Non-Authoritative Information"
    [204]="No Content"
    [205]="Reset Content"
    [206]="Partial Content"
    [207]="Multi-Status"
    [208]="Already Reported"
    [226]="IM Used"
    # Redirection Codes (3xx)
    [300]="Multiple Choices"
    [301]="Moved Permanently"
    [302]="Found"
    [303]="See Other"
    [304]="Not Modified"
    [305]="Use Proxy"
    [306]="Switch Proxy"
    [307]="Temporary Redirect"
    [308]="Permanent Redirect"
    # Client Error Codes (4xx)
    [400]="Bad Request"
    [401]="Unauthorized"
    [402]="Payment Required"
    [403]="Forbidden"
    [404]="Not Found"
    [405]="Method Not Allowed"
    [406]="Not Acceptable"
    [407]="Proxy Authentication Required"
    [408]="Request Timeout"
    [409]="Conflict"
    [410]="Gone"
    [411]="Length Required"
    [412]="Precondition Failed"
    [413]="Request Entity Too Large"
    [414]="Request-URI Too Long"
    [415]="Unsupported Media Type"
    [416]="Requested Range Not Satisfiable"
    [417]="Expectation Failed"
    [418]="I'm a teapot"
    [421]="Misdirected Request"
    [422]="Unprocessable Content"
    [423]="Locked"
    [424]="Failed Dependency"
    [425]="Too Early"
    [426]="Upgrade Required"
    [428]="Precondition Required"
    [429]="Too Many Requests"
    [431]="Request Header Fields Too Large"
    [451]="Unavailable For Legal Reasons"
    # Server Error Codes (5xx)
    [500]="Internal Server Error"
    [501]="Not Implemented"
    [502]="Bad Gateway"
    [503]="Service Unavailable"
    [504]="Gateway Timeout"
    [505]="HTTP Version Not Supported"
    [506]="Variant Also Negotiates"
    [507]="Insufficient Storage"
    [508]="Loop Detected"
    [510]="Not Extended"
    [511]="Network Authentication Required"
    [525]="SSL Handshake Failed"
)

function ez.http.code {
    local key="${1}" k i match
    if [[ -z "${key}" ]]; then
        { for k in "${!EZ_HTTP_CODES[@]}"; do echo "${k}: ${EZ_HTTP_CODES["${k}"]}"; done; } | sort -n
    else
        while [[ "${#key}" < 3 ]]; do key+="x"; done
        if [[ "${key}" = *"x"* || "${key}" = *"X"* ]]; then
            {
                for k in "${!EZ_HTTP_CODES[@]}"; do
                    if ez.string.mask.compare -l "${k}" -r "${key}" -m "x" "X"; then
                        echo "${k}: ${EZ_HTTP_CODES["${k}"]}"
                    fi
                done
            } | sort -n
        else
            echo "${EZ_HTTP_CODES["${key}"]}"
        fi
    fi
}

function ez.netstat {
    local exec_str="" grep_str="listen\|Local Address"
    if [[ "$(uname -s)" = "Darwin" ]]; then
        exec_str="netstat -anv -p UDP -p TCP | grep -i \"listen\|Local Address\""
    else  # Linux
        exec_str="netstat -tulpn | grep -i \"listen\|Local Address\""
    fi
    if [[ -n "${1}" ]]; then exec_str+=" | grep -i \"${1}\|Local Address\""; fi
    eval "${exec_str}"
}

