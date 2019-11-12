function ez_print_table() {
    local usage_string=$(ez_build_usage -o "init" -a "ez_print_table" -d "Read data from a file and print the table, 1st row is the banner")
    usage_string+=$(ez_build_usage -o "add" -a "-cd|--col-delimiter" -d "Column Delimiter, default = \",\"")
    usage_string+=$(ez_build_usage -o "add" -a "-rd|--row-delimiter" -d "Row Delimiter, default = \";\" for --data, \"\\\\n\" for --file")
    usage_string+=$(ez_build_usage -o "add" -a "-f|--file" -d "The input file path")
    usage_string+=$(ez_build_usage -o "add" -a "-d|--data" -d "The input data if file is not provided")
    if [[ ${1} == "" ]] || [[ ${1} == "-h" ]] || [[ ${1} == "--help" ]]; then ez_print_usage "${usage_string}"; return 1; fi
    local col_delimiter=","
    local row_delimiter=""
    local file=""
    local data=""
    while [[ ! -z "${1-}" ]]; do
        case "${1-}" in
            "-cd" | "--col-delimiter") shift; col_delimiter=${1-} ;;
            "-rd" | "--row-delimiter") shift; row_delimiter=${1-} ;;
            "-f" | "--file") shift; file=${1-} ;;
            "-d" | "--data") shift; data=${1-} ;;
            *)
                ez_print_log -l ERROR -m "Unknown argument \"$1\""
                ez_print_usage "${usage_string}"; return 1; ;;
        esac
        if [[ ! -z "${1-}" ]]; then shift; fi
    done
    local rows=()
    local number_of_rows=0
    local table=""
    if ! ez_nonempty_check -n "-cd|--col-delimiter" -v "${col_delimiter}" -o "${usage_string}"; then return 1; fi
    if ez_nonempty_check -s -v "${file}"; then
        if ez_nonempty_check -s -v "${data}"; then
            ez_print_log -l ERROR -m "Please use single source of truth --file or --data, do not provide both"
            ez_print_usage "${usage_string}"; return 1
        fi
        if [ ! -f "${file}" ]; then ez_print_log -l ERROR -m "File \"${file}\" not found"; return 1; fi
        local file_content=$(cat "${file}" | sed "/^\s*$/d")  # Remove empty lines
        if ! ez_nonempty_check -n "${file}" -v "${file_content}"; then return 1; fi
        if ! ez_nonempty_check -s -v "${row_delimiter}"; then
            for line in ${file_content[@]}; do rows+=("${line}"); ((++number_of_rows)); done
        else
            number_of_rows=$(awk -F "${row_delimiter}" "{print NF}" <<< "${file_content}")
            IFS="${row_delimiter}" read -ra rows <<< "${file_content}"
        fi
    else
        if ! ez_nonempty_check -n "-d|--data" -v "${data}"; then return 1; fi
        if ! ez_nonempty_check -s -v "${row_delimiter}"; then row_delimiter=";"; fi
        number_of_rows=$(awk -F "${row_delimiter}" "{print NF}" <<< "${data}")
        IFS="${row_delimiter}" read -ra rows <<< "${data}"
    fi
    for ((row=0; row < "${number_of_rows}"; ++row)); do
        local number_of_columns=$(awk -F "${col_delimiter}" "{print NF}" <<< "${rows[row]}")
        # Add Line Delimiter
        if [[ "${row}" == "0" ]]; then table=$(printf "%s#+" $(ez_string_repeat --substring "#+" --count "${number_of_columns}")); fi
        # Add Header Or Body
        table="${table}\n"
        for ((column=1; column <= "${number_of_columns}"; ++column)); do
            table="${table}$(printf "#| %s" $(awk -F "${col_delimiter}" "{print \$${column}}" <<< "${rows[row]}"))"
        done
        table="${table}#|\n"
        # Add Line Delimiter
        if [[ "${row}" == "0" ]] || [[ $(expr "${row}" + 1) == "${number_of_rows}" ]]; then
            table="${table}$(printf "%s#+" $(ez_string_repeat --substring "#+" --count "${number_of_columns}"))"
        fi
    done
    if [[ "$(ez_get_os_type)" == "macos" ]]; then
        echo -e "${table}" | column -s "#" -t | awk '/^\+/{gsub(" ", "-", $0)}1'
    elif [[ "$(ez_get_os_type)" == "linux" ]]; then
        # linux print table with 2 spaces in front of each line
        echo -e "${table}" | column -s "#" -t | sed "s/^  //" | awk '/^\+/{gsub(" ", "-", $0)}1'
    fi    
}

