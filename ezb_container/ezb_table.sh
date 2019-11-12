function ez_print_table() {
    if ! ez_function_exist; then
        ez_set_argument --short "-cd" --long "--col-delimiter" --required --default "," --info "Column Delimiter" &&
        ez_set_argument --short "-rd" --long "--row-delimiter" --default ";" --info "Row Delimiter, default \"\\n\" for --file" &&
        ez_set_argument --short "-d" --long "--data" --info "The input data if file is not provided" && 
        ez_set_argument --short "-f" --long "--file" --info "The input file path" ||
        return 1
    fi
    ez_ask_for_help "${@}" && ez_function_help && return
    local col_delimiter="$(ez_get_argument --short "-cd" --long "--col-delimiter" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local row_delimiter="$(ez_get_argument --short "-rd" --long "--row-delimiter" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local file="$(ez_get_argument --short "-f" --long "--file" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local data="$(ez_get_argument --short "-d" --long "--data" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local rows=(); local number_of_rows=0; local table=""
    if [[ -n "${file}" ]]; then
        [[ -n "${data}" ]] && ez_log_error "Please use single source of truth --file or --data, do not provide both" && return 1
        [[ ! -f "${file}" ]] && ez_log_error "File \"${file}\" not found" && return 1
        local file_content=$(cat "${file}" | sed "/^\s*$/d")  # Remove empty lines
        [[ -z "${file_content}" ]] && return 1
        if [[ -n "${row_delimiter}" ]]; then
            local line=""; for line in ${file_content[@]}; do rows+=("${line}"); ((++number_of_rows)); done
        else
            number_of_rows=$(awk -F "${row_delimiter}" "{print NF}" <<< "${file_content}")
            IFS="${row_delimiter}" read -ra rows <<< "${file_content}"
        fi
    else
        [[ -z "${data}" ]] && return 1
        [[ -z "${row_delimiter}" ]] && row_delimiter=";"
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
    if [[ "$(ezb_os_name)" == "macos" ]]; then
        echo -e "${table}" | column -s "#" -t | awk '/^\+/{gsub(" ", "-", $0)}1'
    elif [[ "$(ezb_os_name)" == "linux" ]]; then
        # linux print table with 2 spaces in front of each line
        echo -e "${table}" | column -s "#" -t | sed "s/^  //" | awk '/^\+/{gsub(" ", "-", $0)}1'
    fi    
}

