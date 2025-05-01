###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
ez.dependencies.check "jq" || return 1

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez.json.flatten {
    if ez.function.unregistered; then
        ez.argument.set --short "-l" --long "--list-filter" --required --default ".[]" --info "JQ filter to the list field" &&
        ez.argument.set --short "-f" --long "--fields" --type "List" --info "Json Keys" &&
        ez.argument.set --short "-c" --long "--columns" --type "List" --info "Column Headers" &&
        ez.argument.set --short "-k" --long "--sort-column" --default 1 --info "Sort column id, start with 1" &&
        ez.argument.set --short "-n" --long "--sort-numbers" --type "Flag" --info "Sort as numbers" || return 1
    fi; ez.function.help "${@}" --run-with-no-argument || return 0
    local list_filter && list_filter="$(ez.argument.get --short "-l" --long "--list-filter" --arguments "${@}")" &&
    local fields && ez.function.arguments.get_list "fields" "$(ez.argument.get --short "-f" --long "--fields" --arguments "${@}")" &&
    local columns && ez.function.arguments.get_list "columns" "$(ez.argument.get --short "-c" --long "--columns" --arguments "${@}")" &&
    local sort_column && sort_column="$(ez.argument.get --short "-k" --long "--sort-column" --arguments "${@}")" &&
    local sort_numbers && sort_numbers="$(ez.argument.get --short "-n" --long "--sort-numbers" --arguments "${@}")" || return 1
    local f line data=""; while read -r "line"; do data+="${line}"; done; if [[ -n "${line}" ]]; then data+="${line}"; fi
    if [[ -n "${list_filter}" ]]; then list_filter+=" | "; fi
    if [[ -z "${fields[*]}" ]]; then fields=(); for f in $(jq -r "${list_filter}keys_unsorted[]" <<< "${data}" | sort -u); do fields+=(".${f}"); done; fi
    if [[ -z "${columns[*]}" ]]; then local columns=(); for f in "${fields[@]}"; do columns+=("${f}"); done; fi
    echo -e "$(ez.text.format -f "Yellow")$({
        echo "$(ez.join "|" "${columns[@]}")"
        echo -e "$(ez.join "|" $(ez.array.init "${#columns[@]}" "--"))$(ez.text.format -e "ResetAll")"
        jq -r "${list_filter}[$(ez.join ", " "${fields[@]}")] | @tsv" <<< "${data}" | sed "s/\t/|/g" | sed "s/||/| |/g" | sed "s/||/| |/g" \
            | { [[ "${sort_numbers}" = "True" ]] && sort -n -k "${sort_column}" -t "|" || sort -k "${sort_column}" -t "|"; }
    } | column -s "|" -t)"
}
