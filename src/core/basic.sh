###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZ_TRUE="True"
EZ_FALSE="False"
EZ_ALL="All"
EZ_ANY="Any"
EZ_NONE="None"
EZ_INDENT="    "

EZ_LOG_ERROR="ERROR"
EZ_LOG_WARNING="WARNING"
EZ_LOG_INFO="INFO"
EZ_LOG_DEBUG="DEBUG"
EZ_LOG_LEVEL="${EZ_LOG_INFO}"  # Use "ez.log.level.set" to override it

###################################################################################################
# ----------------------------------- EZ-Bash Basic Functions ----------------------------------- #
###################################################################################################
function ez.self.variables { set | grep "^EZ_" --color; }
function ez.self.functions { set | grep "^ez_" | cut -d " " -f 1 | grep "^ez_" --color; }
function ez.state.true { return 0; }
function ez.state.false { return 1; }
function ez.environment.path { echo "${PATH}" | tr ":" "\n"; }

function ez_is_true { [[ "${1}" = "${EZ_TRUE}" ]] && return 0 || return 1; }
function ez_is_false { [[ "${1}" = "${EZ_FALSE}" ]] && return 0 || return 1; }
function ez_is_all { [[ "${1}" = "${EZ_ALL}" ]] && return 0 || return 1; }
function ez_is_any { [[ "${1}" = "${EZ_ANY}" ]] && return 0 || return 1; }
function ez_is_none { [[ "${1}" = "${EZ_NONE}" ]] && return 0 || return 1; }

########################################## Time ###################################################
function ez.time.today { date "+%F"; }
# macos date not support milliseconds, brew install coreutils, use gdate
function ez.time.now { local f="+%F %T"; [[ "$(uname -s)" = "Darwin" ]] && f+=" %Z" || f+=".%3N %Z"; [[ -z "${1}" ]] && date "${f}" || TZ="${1}" date "${f}"; }

######################################### String ##################################################
function ez.character.to_int { printf "%d\n" "'${1}"; }
function ez.character.from_int { printf $(printf "\%o" ${1}); echo; }
function ez.string.size { echo "${#1}"; }
function ez.string.lower { tr "[:upper:]" "[:lower:]" <<< "${@}"; }
function ez.string.upper { tr "[:lower:]" "[:upper:]" <<< "${@}"; }
function ez.string.format { # ${1} = format, ${2} ~ ${n} = ${input_string[@]}
    if [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]]; then
        echo; echo "${EZ_INDENT}[Usage]"; echo "${EZ_INDENT}${FUNCNAME[0]} [Format] [String]"; echo; echo "${EZ_INDENT}[Demo]${EZ_INDENT}[Format]"; 
        local f; for f in "${!EZ_FORMAT_SET[@]}"; do echo -e "${EZ_INDENT}${EZ_FORMAT_SET[${f}]}demo${EZ_FORMAT_SET[ResetAll]}${EZ_INDENT}${f}"; done; echo; return 0
    fi
    echo "${EZ_FORMAT_SET[${1}]}${@:2}${EZ_FORMAT_SET[ResetAll]}"
}
function ez.string.count_items {  # "@@" "@@123@@@xyz@@@@" -> 5
    local delimiter="${1}" string="${@:2}" k=0 count=0; [[ -z "${string}" ]] && echo "${count}" && return
    while [[ "${k}" -lt "${#string}" ]]; do if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then ((++count)) && ((k += ${#delimiter})); else ((++k)); fi; done
    echo "$((++count))"
}
function ez.string.split { # ${1} = array reference, ${2} = delimiter, ${3} ~ ${n} = ${input_string[@]}
    local -n __ez_split_arg_reference="${1}"
    local delimiter="${2}" string="${@:3}" item="" k=0
    __ez_split_arg_reference=()
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then
            __ez_split_arg_reference+=("${item}"); item=""; ((k+=${#delimiter}))
        else
            item+="${string:${k}:1}"; ((++k))
        fi
        [[ "${k}" -ge "${#string}" ]] && __ez_split_arg_reference+=("${item}")
    done
}

# ${1} = delimiter, ${2} ~ ${n} = ${input_list[@]}
function ez.string.join { local d="${1}" o i; for i in "${@:2}"; do [[ -z "${o}" ]] && o="${i}" || o+="${d}${i}"; done; echo "${o}"; }
# IFS can only take 1 character
# function ez.string.join { local IFS="${1}"; shift; echo "${*}"; }

########################################## Array ##################################################
function ez.array.size { echo "${#@}"; }
function ez.array.delete_item() {
    # ${1} = array reference, ${2} = item
    local -n __ez_array_delete_item_arg_reference="${1}"
    local tmp_array=("${__ez_array_delete_item_arg_reference[@]}") item status=1
    __ez_array_delete_item_arg_reference=() 
    for item in "${tmp_array[@]}"; do [[ "${item}" != "${2}" ]] && __ez_array_delete_item_arg_reference+=("${item}") || status=0; done
    return "${status}"
}
function ez.array.delete_index() {
    # ${1} = array reference, ${2} = index
    local -n __ez_array_delete_index_arg_reference="${1}"
    local tmp_array=("${__ez_array_delete_index_arg_reference[@]}") i=0 status=1
    __ez_array_delete_index_arg_reference=() 
    for ((; i < "${#tmp_array[@]}"; ++i)); do [[ "${i}" -ne "${2}" ]] && __ez_array_delete_index_arg_reference+=("${tmp_array[${i}]}") || status=0; done
    return "${status}"
}
function ez.array.quote { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="'${i}'" || o+=" '${i}'"; done; echo "${o}"; }
function ez.array.double_quote { local o i; for i in "${@}"; do [[ -z "${o}" ]] && o="\"${i}\"" || o+=" \"${i}\""; done; echo "${o}"; }

# ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
function ez.array.includes { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 0; done; return 1; }
function ez.array.excludes { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 1; done; return 0; }

######################################## Logging ##################################################
function ez.log.level.set {
    export EZ_LOG_LEVEL="${1}"
}
function ez.log.level.enum {
    case "${1}" in
        "${EZ_LOG_ERROR}") echo 4 ;;
        "${EZ_LOG_WARNING}") echo 3 ;;
        "${EZ_LOG_INFO}") echo 2 ;;
        "${EZ_LOG_DEBUG}") echo 1 ;;
        *) echo 0 ;;
    esac    
}
function ez.log.stack {
    local ignore_top_x="${1}" i="$((${#FUNCNAME[@]} - 1))" stack="" first=0
    [[ -z "${ignore_top_x}" ]] && ignore_top_x=0  # i > 0 to ignore self "ez.log.stack"
    for ((; i > ignore_top_x; i--)); do [ "${first}" -ne 0 ] && stack+="/" || first=1; stack+="${FUNCNAME[${i}]}"; done
    [[ -n "${stack}" ]] && echo "[${stack}]"
}
function ez.log.error {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_ERROR})" ]] && return 0; local color="ForegroundRed"
    (>&2 echo -e "[$(ez.time.now)][${EZ_LOGO}][$(ez.string.format "${color}" "ERROR")]$(ez.log.stack 1) $(ez.string.format "${color}" "${@}")")
}
function ez.log.warning {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_WARNING})" ]] && return 0; local color="ForegroundYellow"
    echo -e "[$(ez.time.now)][${EZ_LOGO}][$(ez.string.format "${color}" "WARNING")]$(ez.log.stack 1) $(ez.string.format "${color}" "${@}")"
}
function ez.log.info {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_INFO})" ]] && return 0
    echo -e "[$(ez.time.now)][${EZ_LOGO}][INFO]$(ez.log.stack 1) ${@}"
}
function ez.log.debug {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_DEBUG})" ]] && return 0; local color="ForegroundLightGray"
    echo -e "[$(ez.time.now)][${EZ_LOGO}][$(ez.string.format "${color}" "DEBUG")]$(ez.log.stack 1) $(ez.string.format "${color}" "${@}")"
}
function ez.log {
    local valid_output_to=("Console" "File" "${EZ_ALL}") logger="INFO" file="" message=() stack=1 output_to="Console"
    local arg_list=("-l" "--logger" "-f" "--file" "-s" "--stack" "-m" "--message" "-o" "--output-to")
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Print log to file in \"EZ-BASH\" standard log format" \
        -a "-l|--logger" -t "String" -d "${logger}" -c "" -i "Logger type" \
        -a "-f|--file" -t "String" -d "${file}" -c "" -i "Path to the log file" \
        -a "-s|--stack" -t "Integer" -d "${stack}" -c "" -i "Hide top x function from stack" \
        -a "-m|--message" -t "List" -d "[$(ez.string.join ", " "${message[@]}")]" -c "" -i "The message to print" \
        -a "-o|--output-to" -t "List" -d "Console" -c "[$(ez.string.join ", " "${valid_output_to[@]}")]" -i "" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-l" | "--logger") shift; logger="${1}"; shift ;;
            "-f" | "--file") shift; file="${1}"; shift ;;
            "-o" | "--output-to") shift; output_to="${1}"; shift ;;
            "-s" | "--stack") shift; stack="${1}"; shift ;;
            "-m" | "--message") shift; while [[ -n "${1}" ]] && ez.array.excludes "${1}" "${arg_list[@]}"; do message+=(${1}); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    if ez.array.excludes "${output_to}" "${valid_output_to[@]}"; then
        ez.log.error "Invalid value \"${output_to}\" for \"-o|--output-to\", please choose from [$(ez.string.join ', ' ${valid_output_to[@]})]"
        return 2
    fi
    if [[ "${output_to}" = "Console" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        if [[ "$(ez.string.lower ${logger})" = "error" ]]; then
            (>&2 echo -e "[$(ez.time.now)][${EZ_LOGO}][$(ez.string.format ForegroundRed ${logger})]$(ez.log.stack ${stack}) ${message[@]}")
        elif [[ "$(ez.string.lower ${logger})" = "warning" ]]; then
            echo -e "[$(ez.time.now)][${EZ_LOGO}][$(ez.string.format ForegroundYellow ${logger})]$(ez.log.stack ${stack}) ${message[@]}"
        else
            echo -e "[$(ez.time.now)][${EZ_LOGO}][${logger}]$(ez.log.stack ${stack}) ${message[@]}"
        fi
    fi
    if [[ "${output_to}" = "File" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        [[ -z "${file}" ]] && file="${EZ_DEFAULT_LOG}"
        # Make sure the log_file exists and you have the write permission
        [[ ! -e "${file}" ]] && touch "${file}"
        [[ ! -f "${file}" ]] && ez.log.error "Log File \"${file}\" not exist" && return 3
        [[ ! -w "${file}" ]] && ez.log.error "Log File \"${file}\" not writable" && return 3
        echo "[$(ez.time.now)][${EZ_LOGO}][${logger}]$(ez.log.stack ${stack}) ${message[@]}" >> "${file}"
    fi
}

#################################### Function Helper ##############################################
function ez.function.usage {
    local argument_list=() type_list=() default_list=() choices_list=() info_list=() description=""
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-D" | "--description") shift; description="${1}"; shift ;;
            "-a" | "--argument") shift; argument_list+=("${1}"); shift ;;
            "-t" | "--type") shift; type_list+=("${1}"); shift ;;
            "-d" | "--default") shift; default_list+=("${1}"); shift ;;
            "-c" | "--choices") shift; choices_list+=("${1}"); shift ;;
            "-i" | "--info") shift; info_list+=("${1}"); shift ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    echo; echo "${EZ_INDENT}[FUNCTION]    ${FUNCNAME[1]}"; [[ -n "${description}" ]] && echo "${EZ_INDENT}[DESCRIPTION] ${description}"; echo
    {
        echo -e "${EZ_INDENT}[ARGUMENTS]#[TYPE]#[DEFAULT]#[CHOICES]#[DESCRIPTION]"  # column delimiter: #
        local i; for ((i = 0; i < ${#argument_list[@]}; ++i)); do
            echo -e "${EZ_INDENT}${argument_list[${i}]}#${type_list[${i}]}#${default_list[${i}]}#${choices_list[${i}]}#${info_list[${i}]}"
        done
    } | sed "s/##/# #/g" | sed "s/##/# #/g" | column -s "#" -t; echo; return  # "###" --sed--> "# ##" --sed--> "# # #" 
}

########################################## Color ##################################################
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
function ez.color.format {
    local foreground=38 background=48 color
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "${EZ_INDENT}[Usage]"
        echo "${EZ_INDENT}${FUNCNAME[0]} [-f|--foreground or -b|--background] [0~255]"
        echo; echo "${EZ_INDENT}[Foreground]"
        for color in {0..255}; do
            printf "${EZ_INDENT}\e[${foreground};5;%sm  %3s  ${EZ_FORMAT_SET[ResetAll]}" "${color}" "${color}"
            # Print 6 colors per line
            [[ $((("${color}" + 1) % 6)) -eq 4 ]] && echo
        done
        echo; echo "${EZ_INDENT}[Background]"
        for color in {0..255}; do
            printf "${EZ_INDENT}\e[${background};5;%sm${EZ_FORMAT_SET[ForegroundBlack]}  %3s  ${EZ_FORMAT_SET[ResetAll]}" \
                   "${color}" "${color}"
            # Print 6 colors per line
            [[ $(((${color} + 1) % 6)) -eq 4 ]] && echo
        done
        echo
        return 0
    fi
    if [[ -n "${2}" ]] && [[ "${2}" -ge 0 ]] && [[ "${2}" -lt 255 ]]; then
        if [[ "${1}" = "-f" ]] || [[ "${1}" = "--foreground" ]]; then
            echo "${EZ_INDENT}\e[${foreground};5;${2}m"; return 0
        elif [[ "${1}" = "-b" ]] || [[ "${1}" = "--background" ]]; then
            echo "${EZ_INDENT}\e[${background};5;${2}m"; return 0
        else
            return 1
        fi
    else
        return 2
    fi
}

################################# Miscellaneous Function ##########################################
function ez.source {
    local path="." depth="" exclude=() arg_list=("-p" "--path" "-d" "--depth" "-e" "--exclude") sh_file=""
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Source a file or a directory recursively" \
        -a "-p|--path" -t "String" -d "${path}" -c "" -i "Path to source" \
        -a "-d|--depth" -t "String" -d "${depth}" -c "" -i "Directory search depth, none for infinity" \
        -a "-e|--exclude" -t "List" -d "[$(ez.string.join ", " "${exclude[@]}")]" -c "" -i "Keywords to exclude" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-p" | "--path") shift; path=${1}; shift ;;
            "-d" | "--depth") shift; depth=${1}; shift ;;
            "-e" | "--exclude") shift; while [[ -n "${1}" ]] && ez.array.excludes "${1}" "${arg_list[@]}"; do exclude+=(${1}); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    [[ -z "${path}" ]] && ez.log.error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    if [[ -d "${path}" ]]; then
        [[ ! -r "${path}" ]] && ez.log.error "Cannot read directory \"${path}\"" && return 1
        [[ -n "${depth}" ]] && depth="-depth ${depth}"
        if [[ -z "${exclude}" ]]; then
            for sh_file in $(find "${path}" -type f -name "*.sh" ${depth}); do
                source "${sh_file}" || { ez.log.error "Failed to source \"${sh_file}\""; return 1; }
            done
        else
            for sh_file in $(find "${path}" -type f -name "*.sh" ${depth} | grep -v $(ez.string.join "\|" "${exclude[@]}")); do
                source "${sh_file}" || { ez.log.error "Failed to source \"${sh_file}\""; return 1; }
            done
        fi
    else
        source "${path}" || { ez.log.error "Failed to source \"${path}\""; return 1; }
    fi
}
