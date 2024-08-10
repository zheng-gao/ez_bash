# Aliases are not expanded when the shell is not interactive
# unless the expand_aliases shell option is set using shopt
shopt -s expand_aliases

alias ez.pipe.strip="sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'"
alias ez.pipe.lstrip="sed 's/^[[:blank:]]*//'"
alias ez.pipe.rstrip="sed 's/[[:blank:]]*$//'"
alias ez.pipe.stats="sort | uniq -c | sort -n"
alias ez.pipe.versions="sed -nre 's/^[^0-9]*(([0-9]+\.)+[0-9]+).*/\1/p'"

function ez.pipe.column {
    local data delimiter="${1}" column="${2}"
    [[ -z "${delimiter}" ]] && delimiter=" "
    [[ -z "${column}" ]] && column=0
    if [[ "${column}" -ge 0 ]]; then
        ((++column))
        while read -r data; do echo "${data}" | awk -F "${delimiter}" "{print \$${column}}"; done
    elif [[ "${column}" -eq -1 ]]; then
        while read -r data; do echo "${data}" | awk -F "${delimiter}" "{print \$NF}"; done
    else
        ((++column))
        while read -r data; do echo "${data}" | awk -F "${delimiter}" "{print \$(NF${column})}"; done
    fi
}

function ez.pipeables.show { alias | grep "EZ.PIPE." --color; }
