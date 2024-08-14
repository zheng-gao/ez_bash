# Aliases are not expanded when the shell is not interactive
# unless the expand_aliases shell option is set using shopt
shopt -s expand_aliases

alias ez.pipe.strip="sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'"
alias ez.pipe.lstrip="sed 's/^[[:blank:]]*//'"
alias ez.pipe.rstrip="sed 's/[[:blank:]]*$//'"
alias ez.pipe.stats="sort | uniq -c | sort -n"
alias ez.pipe.versions="sed -nre 's/^[^0-9]*(([0-9]+\.)+[0-9]+).*/\1/p'"

function ez.pipe.columns.get {
    if ez.function.unregistered; then
        ez.argument.set --short "-id" --long "--input-delimiter" --default "<SPACE>" --info "Default delimiter will ignore continuous spaces" &&
        ez.argument.set --short "-od" --long "--output-delimiter" --default "<SPACE>" &&
        ez.argument.set --short "-c" --long "--columns" --type "List" --default 0 --required --info "Column Numbers" || return 1
    fi; ez.function.help "${@}" || return 0
    local input_delimiter && input_delimiter="$(ez.argument.get --short "-id" --long "--input-delimiter" --arguments "${@}")" &&
    local output_delimiter && output_delimiter="$(ez.argument.get --short "-od" --long "--output-delimiter" --arguments "${@}")" &&
    local columns && ez.function.arguments.get_list "columns" "$(ez.argument.get -s "-c" -l "--columns" -a "${@}")" || return 1
    [[ "${input_delimiter}" = "<SPACE>" ]] && input_delimiter=" "
    [[ "${output_delimiter}" = "<SPACE>" ]] && output_delimiter=" "
    local index column delimiter_x awk_str="{print"; for index in "${!columns[@]}"; do
        column="${columns[${index}]}"; [[ "${index}" -eq 0 ]] && delimiter_x="" || delimiter_x="${output_delimiter}"
        if [[ "${column}" -ge 0 ]]; then awk_str+="\"${delimiter_x}\"\$${column}"
        elif [[ "${column}" -eq -1 ]]; then awk_str+="\"${delimiter_x}\"\$NF"
        else ((++column)); awk_str+="\"${delimiter_x}\"\$(NF${column})"; fi
    done
    awk_str+="}"; while read -r data; do echo "${data}" | awk -F "${input_delimiter}" "${awk_str}"; done
}
