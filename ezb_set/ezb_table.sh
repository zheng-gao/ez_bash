###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
if ! ezb_dependency_check "awk"; then return 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_table_print() {
    if ! ezb_function_exist; then
        ezb_set_arg --short "-cd" --long "--col-delimiter" --required --default "," --info "Column Delimiter" &&
        ezb_set_arg --short "-rd" --long "--row-delimiter" --default ";" --info "Row Delimiter, default \"\\n\" for --file" &&
        ezb_set_arg --short "-d" --long "--data" --info "The input data if file is not provided" && 
        ezb_set_arg --short "-f" --long "--file" --info "The input file path" ||
        return 1
    fi
    ezb_function_usage "${@}" && return
    local col_delimiter; col_delimiter="$(ezb_get_arg --short "-cd" --long "--col-delimiter" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local row_delimiter; row_delimiter="$(ezb_get_arg --short "-rd" --long "--row-delimiter" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local file; file="$(ezb_get_arg --short "-f" --long "--file" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local data; data="$(ezb_get_arg --short "-d" --long "--data" --arguments "${@}")"; [ "${?}" -ne 0 ] && return 1
    local rows=(); local number_of_rows=0; local table=""
    if [[ -n "${file}" ]]; then
        [[ -n "${data}" ]] && ezb_log_error "Please use single source of truth --file or --data, do not provide both" && return 1
        [[ ! -f "${file}" ]] && ezb_log_error "File \"${file}\" not found" && return 1
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
    local row=0; for ((; row < "${number_of_rows}"; ++row)); do
        local number_of_columns=$(awk -F "${col_delimiter}" "{print NF}" <<< "${rows[row]}")
        # Add Line Delimiter
        if [[ "${row}" == "0" ]]; then table=$(printf "%s#+" $(ezb_string_repeat --string "#+" --count "${number_of_columns}")); fi
        # Add Header Or Body
        table="${table}\n"
        local column=1; for ((; column <= "${number_of_columns}"; ++column)); do
            table="${table}$(printf "#| %s" $(awk -F "${col_delimiter}" "{print \$${column}}" <<< "${rows[row]}"))"
        done
        table="${table}#|\n"
        # Add Line Delimiter
        if [[ "${row}" == "0" ]] || [[ $(expr "${row}" + 1) == "${number_of_rows}" ]]; then
            table="${table}$(printf "%s#+" $(ezb_string_repeat --string "#+" --count "${number_of_columns}"))"
        fi
    done
    if [[ "$(ezb_os_name)" == "macos" ]]; then
        echo -e "${table}" | column -s "#" -t | awk '/^\+/{gsub(" ", "-", $0)}1'
    elif [[ "$(ezb_os_name)" == "linux" ]]; then
        # linux print table with 2 spaces in front of each line
        echo -e "${table}" | column -s "#" -t | sed "s/^  //" | awk '/^\+/{gsub(" ", "-", $0)}1'
    fi    
}

