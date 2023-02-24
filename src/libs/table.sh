###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez_dependency_check "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_table_print {
    if ez_function_unregistered; then
        ez_arg_set --short "-cd" --long "--col-delimiter" --required --default "," --info "Column Delimiter" &&
        ez_arg_set --short "-rd" --long "--row-delimiter" --required --default ";" --info "Row Delimiter" &&
        ez_arg_set --short "-d" --long "--data" --exclude "1" --info "The input data if file is not provided" && 
        ez_arg_set --short "-f" --long "--file" --exclude "1" --info "The input file path" || return 1
    fi
    ez_function_usage "${@}" && return
    local col_delimiter && col_delimiter="$(ez_arg_get --short "-cd" --long "--col-delimiter" --arguments "${@}")" &&
    local row_delimiter && row_delimiter="$(ez_arg_get --short "-rd" --long "--row-delimiter" --arguments "${@}")" &&
    local file && file="$(ez_arg_get --short "-f" --long "--file" --arguments "${@}")" &&
    local data && data="$(ez_arg_get --short "-d" --long "--data" --arguments "${@}")" || return 1
    local rows=(); local number_of_rows=0; local table=""
    if [[ -n "${file}" ]]; then
        [[ ! -f "${file}" ]] && ez_log_error "File \"${file}\" not found" && return 1
        local file_content=$(cat "${file}" | sed "/^\s*$/d")  # Remove empty lines
        [[ -z "${file_content}" ]] && return 1
        if [[ "${row_delimiter}" = "\n" ]]; then
            local line; for line in ${file_content[@]}; do rows+=("${line}"); ((++number_of_rows)); done
        else
            number_of_rows=$(ez_count_items "${row_delimiter}" "${file_content}")
            IFS="${row_delimiter}" read -ra rows <<< "${file_content}"
        fi
    else
        [[ -z "${data}" ]] && return 1
        [[ -z "${row_delimiter}" ]] && row_delimiter=";"
        number_of_rows=$(ez_count_items "${row_delimiter}" "${data}")
        IFS="${row_delimiter}" read -ra rows <<< "${data}"
    fi
    local row=0; for ((; row < "${number_of_rows}"; ++row)); do
        local number_of_columns=$(ez_count_items "${col_delimiter}" "${rows[${row}]}")
        # Add Line Delimiter
        if [[ "${row}" -eq 0 ]]; then table=$(printf "%s#+" $(ez_string_repeat --string "#+" --count "${number_of_columns}")); fi
        # Add Header Or Body
        table="${table}\n"
        local column=1; for ((; column <= "${number_of_columns}"; ++column)); do
            table="${table}$(printf "#| %s" $(awk -F "${col_delimiter}" "{print \$${column}}" <<< "${rows[${row}]}"))"
        done
        table="${table}#|\n"
        # Add Line Delimiter
        if [[ "${row}" -eq 0 ]] || [[ "$((row+1))" -eq "${number_of_rows}" ]]; then
            table="${table}$(printf "%s#+" $(ez_string_repeat --string "#+" --count "${number_of_columns}"))"
        fi
    done
    if [[ "$(ez_os_name)" == "macos" ]]; then
        echo -e "${table}" | column -s "#" -t | awk '/^\+/{gsub(" ", "-", $0)}1'
    elif [[ "$(ez_os_name)" == "linux" ]]; then
        # linux print table with 2 spaces in front of each line
        echo -e "${table}" | column -s "#" -t | sed "s/^  //" | awk '/^\+/{gsub(" ", "-", $0)}1'
    fi    
}

