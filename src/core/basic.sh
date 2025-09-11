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
function ez.self.show.alias { alias | grep "ez\." --color; }
function ez.self.show.functions { set | cut -d " " -f 1 | grep "^ez." --color; }
function ez.self.show.variables { set | grep "^EZ_" --color; }

function ez.state.true { return 0; }
function ez.state.false { return 1; }
function ez.environment.path { echo "${PATH}" | tr ":" "\n"; }

function ez.is_true { [[ "${1}" = "${EZ_TRUE}" ]] && return 0 || return 1; }
function ez.is_false { [[ "${1}" = "${EZ_FALSE}" ]] && return 0 || return 1; }
function ez.is_all { [[ "${1}" = "${EZ_ALL}" ]] && return 0 || return 1; }
function ez.is_any { [[ "${1}" = "${EZ_ANY}" ]] && return 0 || return 1; }
function ez.is_none { [[ "${1}" = "${EZ_NONE}" ]] && return 0 || return 1; }

########################################## Time ###################################################
function ez.time.today { date "+%F"; }
# macos date not support milliseconds, brew install coreutils, use gdate
function ez.time.now { local f="+%F %T"; if [[ "$(uname -s)" = "Darwin" ]]; then f+=" %Z"; else f+=".%3N %Z"; fi; date "${f}"; }
######################################### String ##################################################
function ez.character.to_int { printf "%d\n" "'${1}"; }
function ez.character.from_int { printf "%b" "$(printf "\%o" "${1}")\n"; }
function ez.string.size { echo "${#1}"; }
function ez.string.count_items {  # "," "a,b,c" -> 3
    local delimiter="${1}"; [[ -z "${delimiter}" ]] && ez.log.error "Delimiter Not Found" && return 1
    local string="${2}" k=0 count=0; [[ -z "${string}" ]] && echo "${count}" && return
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then ((++count)) && ((k += ${#delimiter})); else ((++k)); fi
    done
    echo "$((++count))"
}

# ${1} = delimiter, ${2} ~ ${n} = ${input_list[@]}
function ez.join {
    local d="${1}"; [[ -z "${d}" ]] && ez.log.error "Delimiter Not Found" && return 1
    local o i first=0; for i in "${@:2}"; do [[ "${first}" -eq 0 ]] && o="${i}" || o+="${d}${i}"; first=1; done; echo "${o}"
}
# IFS can only take 1 character
# function ez.join { local IFS="${1}"; shift; echo "${*}"; }

function ez.quote { echo "'${1}'"; }
function ez.quote.double { echo "\"${1}\""; }
function ez.split { # ${1} = array reference, ${2} = delimiter, ${3} = input string
    local -n ez_split_arg_reference="${1}"; local delimiter="${2}" string="${3}" item="" k=0; ez_split_arg_reference=()
    while [[ "${k}" -lt "${#string}" ]]; do
        if [[ "${string:${k}:${#delimiter}}" = "${delimiter}" ]]; then
            ez_split_arg_reference+=("${item}"); item=""; ((k+=${#delimiter}))
        else
            item+="${string:${k}:1}"; ((++k))
        fi
        if [[ "${k}" -ge "${#string}" ]]; then ez_split_arg_reference+=("${item}"); fi
    done
}
function ez.lower {
    if [[ "${#@}" -le 1 ]]; then tr "[:upper:]" "[:lower:]" <<< "${1}"; return; fi
    local -n ez_lower_arg_reference="${1}"; ez_lower_arg_reference=()
    local i; for i in "${@:2}"; do ez_lower_arg_reference+=("$(tr "[:upper:]" "[:lower:]" <<< "${i}")"); done
}
function ez.upper {
    if [[ "${#@}" -le 1 ]]; then tr "[:lower:]" "[:upper:]" <<< "${1}"; return; fi
    local -n ez_upper_arg_reference="${1}"; ez_upper_arg_reference=()
    local i; for i in "${@:2}"; do ez_upper_arg_reference+=("$(tr "[:lower:]" "[:upper:]" <<< "${i}")"); done
}

########################################## Array ##################################################
# ${1} = Item, ${2} ~ ${n} = ${input_list[@]}
function ez.includes { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 0; done; return 1; }
function ez.excludes { local i; for i in "${@:2}"; do [[ "${1}" = "${i}" ]] && return 1; done; return 0; }

function ez.array.init { local size="${1}" item="${2}"; for ((; size > 0; --size)) do echo "${item}"; done; }
function ez.array.map {
    if [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]]; then
        ez.function.usage -D "Process each item in the array with the given function" \
            -a "-a|--array"    -t "String"  -d "" -c "" -i "Array Variable Name" \
            -a "-f|--function" -t "String"  -d "" -c "" -i "Function Name"
        return
    fi
    local array map_function
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-a" | "--array") shift; array="${1}"; shift ;;
            "-f" | "--function") shift; map_function="${1}"; shift ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    if [[ -z "${array}" ]]; then ez.log.error "Array Not Found."; return 1; fi
    if [[ -z "${map_function}" ]]; then ez.log.error "Map Function Not Found."; return 1; fi
    local -n ez_array_map_arg_reference="${array}" 
    local i=0; for ((; i < "${#ez_array_map_arg_reference[@]}"; ++i)); do
        ez_array_map_arg_reference["${i}"]="$("${map_function}" "${ez_array_map_arg_reference["${i}"]}")"
    done
}
function ez.array.quote { ez.array.map --array "${1}" --function "ez.quote"; }
function ez.array.quote.double { ez.array.map --array "${1}" --function "ez.quote.double"; }
function ez.array.size { echo "${#@}"; }
function ez.array.delete.item() {  # ${1} = array reference, ${2} = item
    local -n ez_array_delete_item_arg_reference="${1}"; local tmp_array=() item
    for item in "${ez_array_delete_item_arg_reference[@]}"; do tmp_array+=("${item}"); done
    ez_array_delete_item_arg_reference=()
    for item in "${tmp_array[@]}"; do
        if [[ "${item}" != "${2}" ]]; then ez_array_delete_item_arg_reference+=("${item}"); fi
    done
}
function ez.array.delete.index() {  # ${1} = array reference, ${2} = index
    local -n ez_array_delete_index_arg_reference="${1}"; local tmp_array=() item index="${2}" i
    for item in "${ez_array_delete_index_arg_reference[@]}"; do tmp_array+=("${item}"); done
    ez_array_delete_index_arg_reference=(); if [[ "${index}" -lt 0 ]]; then (( index += "${#tmp_array[@]}" )); fi
    for ((i=0; i < "${#tmp_array[@]}"; ++i)); do
        if [[ "${i}" -ne "${index}" ]]; then ez_array_delete_index_arg_reference+=("${tmp_array[${i}]}"); fi
    done
}

######################################## Logging ##################################################
function ez.log.level.set { export EZ_LOG_LEVEL="${1}"; }
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
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_ERROR})" ]] && return 0; local color="Red"
    (>&2 echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][$(ez.text.decorate -f "${color}" -t "ERROR")]$(ez.log.stack 1) $(ez.text.decorate -f "${color}" -t "${@}")")
}
function ez.log.warning {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_WARNING})" ]] && return 0; local color="Yellow"
    echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][$(ez.text.decorate -f "${color}" -t "WARNING")]$(ez.log.stack 1) $(ez.text.decorate -f "${color}" -t "${@}")"
}
function ez.log.info {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_INFO})" ]] && return 0
    echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][INFO]$(ez.log.stack 1) ${*}"
}
function ez.log.debug {
    [[ "$(ez.log.level.enum ${EZ_LOG_LEVEL})" -gt "$(ez.log.level.enum ${EZ_LOG_DEBUG})" ]] && return 0; local color="LightGray"
    echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][$(ez.text.decorate -f "${color}" -t "DEBUG")]$(ez.log.stack 1) $(ez.text.decorate -f "${color}" -t "${@}")"
}
function ez.log {
    local valid_output_to=("Console" "File" "${EZ_ALL}") logger="INFO" file="" message=() stack=1 output_to="Console"
    local arg_list=("-l" "--logger" "-f" "--file" "-s" "--stack" "-m" "--message" "-o" "--output-to")
    if [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]]; then
        ez.function.usage -D "Print log to file in \"EZ-BASH\" standard log format" \
            -a "-l|--logger"    -t "String"  -d "${logger}" -c ""                                          -i "Logger type" \
            -a "-f|--file"      -t "String"  -d "${file}"   -c ""                                          -i "Path to the log file" \
            -a "-s|--stack"     -t "Integer" -d "${stack}"  -c ""                                          -i "Hide top x function from stack" \
            -a "-m|--message"   -t "List"    -d ""          -c ""                                          -i "The message to print" \
            -a "-o|--output-to" -t "List"    -d "Console"   -c "[$(ez.join ", " "${valid_output_to[@]}")]" -i ""
        return
    fi
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-l" | "--logger") shift; logger="${1}"; shift ;;
            "-f" | "--file") shift; file="${1}"; shift ;;
            "-o" | "--output-to") shift; output_to="${1}"; shift ;;
            "-s" | "--stack") shift; stack="${1}"; shift ;;
            "-m" | "--message") shift; while [[ -n "${1}" ]] && ez.excludes "${1}" "${arg_list[@]}"; do message+=("${1}"); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    if ez.excludes "${output_to}" "${valid_output_to[@]}"; then
        ez.log.error "Invalid value \"${output_to}\" for \"-o|--output-to\", please choose from [$(ez.join ', ' "${valid_output_to[@]}")]"
        return 2
    fi
    if [[ "${output_to}" = "Console" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        if [[ "$(ez.lower "${logger}")" = "error" ]]; then
            (>&2 echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][$(ez.text.decorate -f "Red" -t "${logger}")]$(ez.log.stack "${stack}") ${message[*]}")
        elif [[ "$(ez.lower "${logger}")" = "warning" ]]; then
            echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][$(ez.text.decorate -f "Yellow" -t "${logger}")]$(ez.log.stack "${stack}") ${message[*]}"
        else
            echo -e "[$(ez.time.now)][${EZ_SELF_LOGO}][${logger}]$(ez.log.stack "${stack}") ${message[*]}"
        fi
    fi
    if [[ "${output_to}" = "File" ]] || [[ "${output_to}" = "${EZ_ALL}" ]]; then
        [[ -z "${file}" ]] && file="${EZ_DEFAULT_LOG}"
        # Make sure the log_file exists and you have the write permission
        [[ ! -e "${file}" ]] && touch "${file}"
        [[ ! -f "${file}" ]] && ez.log.error "Log File \"${file}\" not exist" && return 3
        [[ ! -w "${file}" ]] && ez.log.error "Log File \"${file}\" not writable" && return 3
        echo "[$(ez.time.now)][${EZ_SELF_LOGO}][${logger}]$(ez.log.stack "${stack}") ${message[*]}" >> "${file}"
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
unset EZ_TEXT_EFFECT_SET
declare -g -A EZ_TEXT_EFFECT_SET=(
    ["Bold"]=1
    ["Dim"]=2
    ["Italic"]=3
    ["Underlined"]=4
    ["Blink"]=5
    ["Reverse"]=7       # invert the foreground and background colors
    ["Hidden"]=8        # useful for passwords
    # ["StrikeThrough"]=9
    ["ResetAll"]=0
    ["ResetBold"]=21
    ["ResetDim"]=22
    ["ResetItalic"]=23
    ["ResetUnderlined"]=24
    ["ResetBlink"]=25
    ["ResetReverse"]=27
    ["ResetHidden"]=28
    # ["ResetStrikeThrough"]="\e[29m"
)
unset EZ_TEXT_FOREGROUND_COLOR_SET
declare -g -A EZ_TEXT_FOREGROUND_COLOR_SET=(
    ["Default"]=39
    ["Black"]=30
    ["Red"]=31
    ["Green"]=32
    ["Yellow"]=33
    ["Blue"]=34
    ["Magenta"]=35
    ["Cyan"]=36
    ["LightGray"]=37
    ["DarkGray"]=90
    ["LightRed"]=91
    ["LightGreen"]=92
    ["LightYellow"]=93
    ["LightBlue"]=94
    ["LightMagenta"]=95
    ["LightCyan"]=96
    ["White"]=97
)
unset EZ_TEXT_BACKGROUND_COLOR_SET
declare -g -A EZ_TEXT_BACKGROUND_COLOR_SET=(
    ["Default"]=49
    ["Black"]=40
    ["Red"]=41
    ["Green"]=42
    ["Yellow"]=43
    ["Blue"]=44
    ["Magenta"]=45
    ["Cyan"]=46
    ["LightGray"]=47
    ["DarkGray"]=100
    ["LightRed"]=101
    ["LightGreen"]=102
    ["LightYellow"]=103
    ["LightBlue"]=104
    ["LightMagenta"]=105
    ["LightCyan"]=106
    ["White"]=107
)
function ez.text.format {
    local effect f_color b_color output="\e["
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Format text to add effect and color" \
        -a "-e|--effect" -t "String" -d "${effect}" -c "${!EZ_TEXT_EFFECT_SET[*]}" -i "" \
        -a "-f|--foreground-color" -t "String" -d "${f_color}" -c "${!EZ_TEXT_FOREGROUND_COLOR_SET[*]}" -i "" \
        -a "-b|--background-color" -t "String" -d "${b_color}" -c "${!EZ_TEXT_BACKGROUND_COLOR_SET[*]}" -i "" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-e" | "--effect") shift; effect="${1}"; shift ;;
            "-f" | "--foreground-color") shift; f_color="${1}"; shift ;;
            "-b" | "--background-color") shift; b_color="${1}"; shift ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    if [[ -n "${effect}" ]]; then
        if ez.excludes "${effect}" "${!EZ_TEXT_EFFECT_SET[@]}"; then ez.log.error "Invalid Effect: ${effect}"; return 1; fi
        output+="${EZ_TEXT_EFFECT_SET["${effect}"]}"
    fi
    if [[ -n "${f_color}" ]]; then
        if ez.excludes "${f_color}" "${!EZ_TEXT_FOREGROUND_COLOR_SET[@]}"; then ez.log.error "Invalid Foreground Color: ${f_color}"; return 1; fi
        output+=";${EZ_TEXT_FOREGROUND_COLOR_SET["${f_color}"]}"
    fi
    if [[ -n "${b_color}" ]]; then
        if ez.excludes "${b_color}" "${!EZ_TEXT_BACKGROUND_COLOR_SET[@]}"; then ez.log.error "Invalid Background Color: ${b_color}"; return 1; fi
        output+=";${EZ_TEXT_BACKGROUND_COLOR_SET["${b_color}"]}"
    fi
    echo "${output}m"
}
function ez.text.decorate {
    if [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]]; then
        echo; echo "${EZ_INDENT}[Usage]"; echo "${EZ_INDENT}${FUNCNAME[0]} [Options] -t|--text [Text]"; echo
        echo "${EZ_INDENT}[Demo]    [Options]"; local f
        for f in "${!EZ_TEXT_EFFECT_SET[@]}"; do
            if [[ "${f}" =~ "Reset"* ]]; then continue; fi
            echo -e "${EZ_INDENT}$(ez.text.format -e "${f}")demo$(ez.text.format -e "ResetAll")      -e|--effect ${f}"
        done
        for f in "${!EZ_TEXT_FOREGROUND_COLOR_SET[@]}"; do
            echo -e "${EZ_INDENT}$(ez.text.format -f "${f}")demo$(ez.text.format -e "ResetAll")      -f|--foreground ${f}"
        done
        for f in "${!EZ_TEXT_BACKGROUND_COLOR_SET[@]}"; do
            echo -e "${EZ_INDENT}$(ez.text.format -b "${f}")demo$(ez.text.format -e "ResetAll")      -b|--background ${f}"
        done
        echo
        return 0
    fi
    local effect f_color b_color text=() text_format
    local arg_list=("-e" "--effect" "-f" "--foreground-color" "-b" "--background-color" "-t" "--text")
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-e" | "--effect") shift; effect="${1}"; shift ;;
            "-f" | "--foreground-color") shift; f_color="${1}"; shift ;;
            "-b" | "--background-color") shift; b_color="${1}"; shift ;;
            "-t" | "--text") shift; while [[ -n "${1}" ]] && ez.excludes "${1}" "${arg_list[@]}"; do text+=("${1}"); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    text_format="$(ez.text.format -e "${effect}" -f "${f_color}" -b "${b_color}")" || return 1
    echo "${text_format}${text[*]}$(ez.text.format -e "ResetAll")"
}
function ez.text.color {
    local foreground=38 background=48 color
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "${EZ_INDENT}[Usage]"
        echo "${EZ_INDENT}${FUNCNAME[0]} [-f|--foreground or -b|--background] [0~255]"
        echo; echo "${EZ_INDENT}[Foreground]"
        for color in {0..255}; do
            printf "${EZ_INDENT}\e[${foreground};5;%sm  %3s  $(ez.text.format -e 'ResetAll')" "${color}" "${color}"
            # Print 6 colors per line
            [[ $(((color + 1) % 6)) -eq 4 ]] && echo
        done
        echo; echo "${EZ_INDENT}[Background]"
        for color in {0..255}; do
            printf "${EZ_INDENT}\e[${background};5;%sm  %3s  $(ez.text.format -e 'ResetAll')" "${color}" "${color}"
            # Print 6 colors per line
            [[ $(((color + 1) % 6)) -eq 4 ]] && echo
        done
        echo
        return 0
    fi
    if [[ -n "${2}" ]] && [[ "${2}" -ge 0 ]] && [[ "${2}" -lt 255 ]]; then
        if [[ "${1}" = "-f" ]] || [[ "${1}" = "--foreground" ]]; then
            # shellcheck disable=SC2028
            echo "${EZ_INDENT}\e[${foreground};5;${2}m"; return 0  
        elif [[ "${1}" = "-b" ]] || [[ "${1}" = "--background" ]]; then
            # shellcheck disable=SC2028
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
    local path="." depth="" exclude=() arg_list=("-p" "--path" "-d" "--depth" "-e" "--exclude") sh_file="" exec_str
    [[ -z "${1}" || "${1}" = "-h" || "${1}" = "--help" ]] && ez.function.usage -D "Source a file or a directory recursively" \
        -a "-p|--path" -t "String" -d "${path}" -c "" -i "Path to source" \
        -a "-d|--depth" -t "Integer" -d "${depth}" -c "" -i "Directory search depth, none for infinity" \
        -a "-e|--exclude" -t "List" -d "[$(ez.join ", " "${exclude[@]}")]" -c "" -i "Keywords to exclude" && return 0
    while [[ -n "${1}" ]]; do
        case "${1}" in
            "-p" | "--path") shift; path="${1}"; shift ;;
            "-d" | "--depth") shift; depth="${1}"; shift ;;
            "-e" | "--exclude") shift; while [[ -n "${1}" ]] && ez.excludes "${1}" "${arg_list[@]}"; do exclude+=("${1}"); shift; done ;;
            *) ez.log.error "Unknown argument identifier \"${1}\". Run \"${FUNCNAME[0]} --help\" for details"; return 1 ;;
        esac
    done
    [[ -z "${path}" ]] && ez.log.error "Invalid value \"${path}\" for \"-p|--path\"" && return 1
    path="${path%/}" # Remove a trailing slash if there is one
    if [[ -d "${path}" ]]; then
        [[ ! -r "${path}" ]] && ez.log.error "Cannot read directory \"${path}\"" && return 1
        exec_str="find '${path}' -type f -name '*.sh'"
        if [[ -n "${depth}" ]]; then exec_str+=" -depth ${depth}"; fi
        if [[ -n "${exclude[*]}" ]]; then exec_str+=" | grep -v $(ez.join "\|" "${exclude[@]}")"; fi
        exec_str+=" | sort"
        for sh_file in $(eval "${exec_str}"); do
            # shellcheck disable=SC1090
            if ! source "${sh_file}"; then ez.log.error "Failed to source \"${sh_file}\""; return 1; fi
        done
    else
        # shellcheck disable=SC1090
        if ! source "${path}"; then ez.log.error "Failed to source \"${path}\""; return 1; fi
    fi
}
