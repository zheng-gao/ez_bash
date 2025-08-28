# Aliases are not expanded when the shell is not interactive
# unless the expand_aliases shell option is set using shopt
shopt -s expand_aliases

# Pipeable Alias
alias ez.strip="sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'"
alias ez.lstrip="sed 's/^[[:blank:]]*//'"
alias ez.rstrip="sed 's/[[:blank:]]*$//'"
alias ez.stats="sort | uniq -c | sort -n"
alias ez.versions="sed -nre 's/^[^0-9]*(([0-9]+\.)+[0-9]+).*/\1/p'"
