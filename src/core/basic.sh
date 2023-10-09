###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_TRUE="True"
EZ_FALSE="False"
EZ_ALL="All"
EZ_ANY="Any"
EZ_NONE="None"

###################################################################################################
# ------------------------------------- EZB Basic Functions ------------------------------------- #
###################################################################################################
function ez_show_variables { set | grep "^EZ_" --color; }
function ez_show_functions { set | grep "^ez_" | cut -d " " -f 1 | grep "^ez_" --color; }

function ez_is_true { [[ "${1}" = "${EZ_TRUE}" ]] && return 0 || return 1; }
function ez_is_false { [[ "${1}" = "${EZ_FALSE}" ]] && return 0 || return 1; }
function ez_is_all { [[ "${1}" = "${EZ_ALL}" ]] && return 0 || return 1; }
function ez_is_any { [[ "${1}" = "${EZ_ANY}" ]] && return 0 || return 1; }
function ez_is_none { [[ "${1}" = "${EZ_NONE}" ]] && return 0 || return 1; }

function ez_chr { printf $(printf "\%o" ${1}); }
function ez_ord { printf "%d\n" "'${1}"; }
function ez_lower { tr "[:upper:]" "[:lower:]" <<< "${@}"; }
function ez_upper { tr "[:lower:]" "[:upper:]" <<< "${@}"; }
function ez_now { [[ -z "${1}" ]] && date "+%F %T %Z" || TZ="${1}" date "+%F %T %Z"; }
function ez_today { date "+%F"; }
function ez_quote { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="'${i}'" || o+=" '${i}'"; done; echo "${o}"; }
function ez_double_quote { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="\"${i}\"" || o+=" \"${i}\""; done; echo "${o}"; }

function ez_array_size { echo "${#@}"; }
function ez_string_size { echo "${#1}"; }

# ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
function ez_contains { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 0; done; return 1; }
function ez_excludes { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 1; done; return 0; }

# ${1} = delimiter, ${2} ~ ${n} = ${input_list[@]}
function ez_join { local d="${1}" o i; for i in "${@:2}"; do [[ -z "${o}" ]] && o="${i}" || o+="${d}${i}"; done; echo "${o}"; }

# IFS can only take 1 character
# function ez_join { local IFS="${1}"; shift; echo "${*}"; } 

function ez_os_name {
    case "$(uname -s)" in
        "Darwin") echo "macos" && return 0 ;;
        "Linux") echo "linux" && return 0 ;;
        *) echo "unknown" && return 1 ;;
    esac
}

function ez_timeout {
    local os=$(ez_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! which "gtimeout" > "/dev/null"; then ez_log_error "Not found \"gtimeout\", please run \"brew install coreutils\""
        else echo "gtimeout"; fi
    elif [[ "${os}" = "linux" ]]; then
        if ! which "timeout" > "/dev/null"; then ez_log_error "Not found \"timeout\", please run \"yum install timeout\""
        else echo "timeout"; fi # Should be installed by default
    fi
}

function ez_md5 {
    local os=$(ez_os_name)
    if [[ "${os}" = "macos" ]]; then
        if ! hash "md5"; then ez_log_error "Not found \"md5\", please run \"brew install md5\""
        else echo "md5 -q"; fi
    elif [[ "${os}" = "linux" ]]; then
        if ! hash "md5sum"; then ez_log_error "Not found \"md5sum\", please run \"yum install md5sum\""
        else echo "md5sum"; fi
    fi
}

function ez_count_items {
    local delimiter="${1}" string="${@:2}" k=0 count=0
    [[ -z "${string}" ]] && echo "${count}" && return
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then ((++count)) && ((k += ${#delimiter})); else ((++k)); fi
    done
    echo "$((++count))"
}

function ez_log_stack {
    local ignore_top_x="${1}" i=$((${#FUNCNAME[@]} - 1)) stack
    if [[ -n "${ignore_top_x}" ]]; then
        for ((; i > ignore_top_x; i--)); do stack+="[${FUNCNAME[${i}]}]"; done
    else
        # i > 0 to ignore self "ez_log_stack"
        for ((; i > 0; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    fi
    [[ "${stack}" != "[]" ]] && echo "${stack}"
}

function ez_split {
    # ${1} = array reference, ${2} = delimiter, ${3} ~ ${n} = ${input_string[@]}
    local -n ez_split_arg_reference="${1}"
    local delimiter="${2}" string="${@:3}" item="" k=0
    ez_split_arg_reference=()
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then
            ez_split_arg_reference+=("${item}"); item=""; ((k+=${#delimiter}))
        else
            item+="${string:${k}:1}"; ((++k))
        fi
        [[ "${k}" -ge "${#string}" ]] && ez_split_arg_reference+=("${item}")
    done
}

function ez_array_delete_item() {
    # ${1} = array reference, ${2} = item
    local -n ez_array_delete_item_arg_reference="${1}"
    local tmp_array=("${ez_array_delete_item_arg_reference[@]}") item status=1
    ez_array_delete_item_arg_reference=() 
    for item in "${tmp_array[@]}"; do
        [[ "${item}" != "${2}" ]] && ez_array_delete_item_arg_reference+=("${item}") || status=0
    done
    return "${status}"
}

function ez_array_delete_index() {
    # ${1} = array reference, ${2} = index
    local -n ez_array_delete_index_arg_reference="${1}"
    local tmp_array=("${ez_array_delete_index_arg_reference[@]}") i=0 status=1
    ez_array_delete_index_arg_reference=() 
    for ((; i < "${#tmp_array[@]}"; ++i)); do
        [[ "${i}" -ne "${2}" ]] && ez_array_delete_index_arg_reference+=("${tmp_array[${i}]}") || status=0
    done
    return "${status}"
}

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
unset EZ_FORMAT_SET
declare -g -A EZ_FORMAT_SET=(
# Formatting
    # Set
    ["Bold"]="\e[1m"
    ["Dim"]="\e[2m"
    ["Italic"]="\e[3m"
    ["Underlined"]="\e[4m"
    ["Blink"]="\e[5m"
    ["Reverse"]="\e[7m" # invert the foreground and background colors
    ["Hidden"]="\e[8m" # useful for passwords
    # ["StrikeThrough"]="\e[9m"
    # Reset
    ["ResetAll"]="\e[0m"
    ["ResetBold"]="\e[21m"
    ["ResetDim"]="\e[22m"
    ["ResetItalic"]="\e[23m"
    ["ResetUnderlined"]="\e[24m"
    ["ResetBlink"]="\e[25m"
    ["ResetReverse"]="\e[27m"
    ["ResetHidden"]="\e[28m"
    # ["ResetStrikeThrough"]="\e[29m"
# Colors
    # Foreground
    ["ForegroundDefault"]="\e[39m"
    ["ForegroundBlack"]="\e[30m"
    ["ForegroundRed"]="\e[31m"
    ["ForegroundGreen"]="\e[32m"
    ["ForegroundYellow"]="\e[33m"
    ["ForegroundBlue"]="\e[34m"
    ["ForegroundMagenta"]="\e[35m"
    ["ForegroundCyan"]="\e[36m"
    ["ForegroundLightGray"]="\e[37m"
    ["ForegroundDarkGray"]="\e[90m"
    ["ForegroundLightRed"]="\e[91m"
    ["ForegroundLightGreen"]="\e[92m"
    ["ForegroundLightYellow"]="\e[93m"
    ["ForegroundLightBlue"]="\e[94m"
    ["ForegroundLightMagenta"]="\e[95m"
    ["ForegroundLightCyan"]="\e[96m"
    ["ForegroundWhite"]="\e[97m"
    # Background
    ["BackgroundDefault"]="\e[49m"
    ["BackgroundBlack"]="\e[40m"
    ["BackgroundRed"]="\e[41m"
    ["BackgroundGreen"]="\e[42m"
    ["BackgroundYellow"]="\e[43m"
    ["BackgroundBlue"]="\e[44m"
    ["BackgroundMagenta"]="\e[45m"
    ["BackgroundCyan"]="\e[46m"
    ["BackgroundLightGray"]="\e[47m"
    ["BackgroundDarkGray"]="\e[100m"
    ["BackgroundLightRed"]="\e[101m"
    ["BackgroundLightGreen"]="\e[102m"
    ["BackgroundLightYellow"]="\e[103m"
    ["BackgroundLightBlue"]="\e[104m"
    ["BackgroundLightMagenta"]="\e[105m"
    ["BackgroundLightCyan"]="\e[106m"
    ["BackgroundWhite"]="\e[107m"
)

function ez_256_color_format {
    local foreground=38 background=48 color
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "[Usage]"
        echo "${FUNCNAME[0]} [-f|--foreground or -b|--background] [0~255]"
        echo; echo "[Foreground]"
        for color in {0..255}; do
            printf "\e[${foreground};5;%sm  %3s  ${EZ_FORMAT_SET[ResetAll]}" "${color}" "${color}"
            # Print 6 colors per line
            [[ $((("${color}" + 1) % 6)) -eq 4 ]] && echo
        done
        echo; echo "[Background]"
        for color in {0..255}; do
            printf "\e[${background};5;%sm${EZ_FORMAT_SET[ForegroundBlack]}  %3s  ${EZ_FORMAT_SET[ResetAll]}" \
                   "${color}" "${color}"
            # Print 6 colors per line
            [[ $(((${color} + 1) % 6)) -eq 4 ]] && echo
        done
        echo
        return 0
    fi
    if [[ -n "${2}" ]] && [[ "${2}" -ge 0 ]] && [[ "${2}" -lt 255 ]]; then
        if [[ "${1}" = "-f" ]] || [[ "${1}" = "--foreground" ]]; then
            echo "\e[${foreground};5;${2}m"; return 0
        elif [[ "${1}" = "-b" ]] || [[ "${1}" = "--background" ]]; then
            echo "\e[${background};5;${2}m"; return 0
        else
            return 1
        fi
    else
        return 2
    fi
}

function ez_string_format {
    # ${1} = format, ${2} ~ ${n} = ${input_string[@]}
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "[Usage]"; echo "${FUNCNAME[0]} [Format] [String]"; echo; echo "[Available Format]"
        local format; for format in "${!EZ_FORMAT_SET[@]}"; do
            echo -e "    ${EZ_FORMAT_SET[${format}]}demo${EZ_FORMAT_SET[ResetAll]}    ${format}"
        done
        echo
    else
        echo "${EZ_FORMAT_SET[${1}]}${@:2}${EZ_FORMAT_SET[ResetAll]}"
    fi
}

function ez_log_info { echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack 1)[INFO] ${@}"; }

function ez_log_error {
    (>&2 echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack 1)[$(ez_string_format "ForegroundRed" "ERROR")] ${@}")
}

function ez_log_warning {
    echo -e "[$(ez_now)][${EZ_LOGO}]$(ez_log_stack 1)[$(ez_string_format "ForegroundYellow" "WARNING")] ${@}"
}
