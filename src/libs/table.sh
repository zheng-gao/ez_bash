###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "awk" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.table.print {
    if ez.function.is_unregistered; then
        ez.argument.set --short "-cd" --long "--col-delimiter" --required --default "," --info "Column Delimiter" &&
        ez.argument.set --short "-rd" --long "--row-delimiter" --required --default ";" --info "Row Delimiter" &&
        ez.argument.set --short "-d" --long "--data" --exclude "1" --info "The input data if file is not provided" && 
        ez.argument.set --short "-f" --long "--file" --exclude "1" --info "The input file path" || return 1
    fi; ez.function.help "${@}" || return 0
    local col_delimiter && col_delimiter="$(ez.argument.get --short "-cd" --long "--col-delimiter" --arguments "${@}")" &&
    local row_delimiter && row_delimiter="$(ez.argument.get --short "-rd" --long "--row-delimiter" --arguments "${@}")" &&
    local file && file="$(ez.argument.get --short "-f" --long "--file" --arguments "${@}")" &&
    local data && data="$(ez.argument.get --short "-d" --long "--data" --arguments "${@}")" || return 1
    local rows=(); local number_of_rows=0; local table=""
    if [[ -n "${file}" ]]; then
        [[ ! -f "${file}" ]] && ez.log.error "File \"${file}\" not found" && return 1
        local file_content=$(cat "${file}" | sed "/^\s*$/d")  # Remove empty lines
        [[ -z "${file_content}" ]] && return 1
        if [[ "${row_delimiter}" = "\n" ]]; then
            local line; for line in ${file_content[@]}; do rows+=("${line}"); ((++number_of_rows)); done
        else
            number_of_rows=$(ez.string.count_items "${row_delimiter}" "${file_content}")
            IFS="${row_delimiter}" read -ra rows <<< "${file_content}"
        fi
    else
        [[ -z "${data}" ]] && return 1
        [[ -z "${row_delimiter}" ]] && row_delimiter=";"
        number_of_rows=$(ez.string.count_items "${row_delimiter}" "${data}")
        IFS="${row_delimiter}" read -ra rows <<< "${data}"
    fi
    local row=0; for ((; row < "${number_of_rows}"; ++row)); do
        local number_of_columns=$(ez.string.count_items "${col_delimiter}" "${rows[${row}]}")
        # Add Line Delimiter
        if [[ "${row}" -eq 0 ]]; then table=$(printf "%s#+" $(ez.string.repeat --string "#+" --count "${number_of_columns}")); fi
        # Add Header Or Body
        table="${table}\n"
        local column=1; for ((; column <= "${number_of_columns}"; ++column)); do
            table="${table}$(printf "#| %s" $(awk -F "${col_delimiter}" "{print \$${column}}" <<< "${rows[${row}]}"))"
        done
        table="${table}#|\n"
        # Add Line Delimiter
        if [[ "${row}" -eq 0 ]] || [[ "$((row+1))" -eq "${number_of_rows}" ]]; then
            table="${table}$(printf "%s#+" $(ez.string.repeat --string "#+" --count "${number_of_columns}"))"
        fi
    done
    if [[ "$(uname -s)" = "Darwin" ]]; then
        echo -e "${table}" | column -s "#" -t | awk '/^\+/{gsub(" ", "-", $0)}1'
    else  # Linux print table with 2 spaces in front of each line
        echo -e "${table}" | column -s "#" -t | sed "s/^  //" | awk '/^\+/{gsub(" ", "-", $0)}1'
    fi    
}

