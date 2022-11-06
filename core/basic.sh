###################################################################################################
# ------------------------------------ Independent Functions ------------------------------------ #
###################################################################################################
function ezb_variables() { set | grep "^EZB_" --color; }
function ezb_functions() { set | grep "^ezb_" | cut -d " " -f 1 | grep "^ezb_" --color; }
function ezb_lower() { tr "[:upper:]" "[:lower:]" <<< "${@}"; }
function ezb_upper() { tr "[:lower:]" "[:upper:]" <<< "${@}"; }
function ezb_now() { date "+%F %T"; }
function ezb_today() { date "+%F"; }
function ezb_command_check() { which "${1}" &> "/dev/null" && return 0 || return 1; }
function ezb_quote() { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="'${i}'" || o+=" '${i}'"; done; echo "${o}"; }
function ezb_double_quote() { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="\"${i}\"" || o+=" \"${i}\""; done; echo "${o}"; }

function ezb_list_size() { echo "${#@}"; }
function ezb_string_size() { echo "${#1}"; }

# ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
function ezb_contains() { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 0; done; return 1; }
function ezb_excludes() { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 1; done; return 0; }

# ${1} = delimiter, ${2} ~ ${n} = ${input_list[@]}
function ezb_join() { local d="${1}" o i; for i in "${@:2}"; do [[ -z "${o}" ]] && o="${i}" || o+="${d}${i}"; done; echo "${o}"; }

function ezb_os_name() {
    case "$(uname -s)" in
        "Darwin") echo "macos" && return 0 ;;
        "Linux") echo "linux" && return 0 ;;
        *) echo "unknown" && return 1 ;;
    esac
}

function ezb_count_items() {
    local delimiter="${1}" string="${@:2}" k=0 count=0
    [[ -z "${string}" ]] && echo "${count}" && return
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then ((++count)) && ((k += ${#delimiter})); else ((++k)); fi
    done
    echo "$((++count))"
}

function ezb_log_stack() {
    local ignore_top_x="${1}" i=$((${#FUNCNAME[@]} - 1)) stack
    if [[ -n "${ignore_top_x}" ]]; then
        for ((; i > ignore_top_x; i--)); do stack+="[${FUNCNAME[${i}]}]"; done
    else
        # i > 0 to ignore self "ezb_log_stack"
        for ((; i > 0; i--)); do stack+="[${FUNCNAME[$i]}]"; done
    fi
    [[ "${stack}" != "[]" ]] && echo "${stack}"
}

function ezb_split() {
    # ${1} = list reference, ${2} = delimiter, ${3} ~ ${n} = ${input_string[@]}
    local -n ezb_split_arg_reference="${1}"
    local delimiter="${2}" string="${@:3}" item="" k=0
    ezb_split_arg_reference=()
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then
            ezb_split_arg_reference+=("${item}"); item=""; ((k+=${#delimiter}))
        else
            item+="${string:${k}:1}"; ((++k))
        fi
        [[ "${k}" -ge "${#string}" ]] && ezb_split_arg_reference+=("${item}")
    done
}

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
unset EZB_FORMAT_SET
declare -g -A EZB_FORMAT_SET=(
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

function ezb_256_color_format() {
    local foreground=38 background=48 color
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "[Usage]"
        echo "${FUNCNAME[0]} [-f|--foreground or -b|--background] [0~255]"
        echo; echo "[Foreground]"
        for color in {0..255}; do
            printf "\e[${foreground};5;%sm  %3s  ${EZB_FORMAT_SET[ResetAll]}" "${color}" "${color}"
            # Print 6 colors per line
            [[ $((("${color}" + 1) % 6)) -eq 4 ]] && echo
        done
        echo; echo "[Background]"
        for color in {0..255}; do
            printf "\e[${background};5;%sm${EZB_FORMAT_SET[ForegroundBlack]}  %3s  ${EZB_FORMAT_SET[ResetAll]}" \
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

function ezb_string_format() {
    # ${1} = format, ${2} ~ ${n} = ${input_string[@]}
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "[Usage]"; echo "${FUNCNAME[0]} [Format] [String]"; echo; echo "[Available Format]"
        local format; for format in "${!EZB_FORMAT_SET[@]}"; do
            echo -e "    ${EZB_FORMAT_SET[${format}]}demo${EZB_FORMAT_SET[ResetAll]}    ${format}"
        done
        echo
    else
        echo "${EZB_FORMAT_SET[${1}]}${@:2}${EZB_FORMAT_SET[ResetAll]}"
    fi
}

function ezb_log_info() { echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack 1)[INFO] ${@}"; }

function ezb_log_error() {
    (>&2 echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack 1)[$(ezb_string_format "ForegroundRed" "ERROR")] ${@}")
}

function ezb_log_warning() {
    echo -e "[$(ezb_now)][${EZB_LOGO}]$(ezb_log_stack 1)[$(ezb_string_format "ForegroundYellow" "WARNING")] ${@}"
}
