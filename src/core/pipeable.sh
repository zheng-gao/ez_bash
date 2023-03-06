# Aliases are not expanded when the shell is not interactive
# unless the expand_aliases shell option is set using shopt
shopt -s expand_aliases

alias EZ_PIPE_STRIP="sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'"
alias EZ_PIPE_LSTRIP="sed 's/^[[:blank:]]*//'"
alias EZ_PIPE_RSTRIP="sed 's/[[:blank:]]*$//'"
alias EZ_PIPE_STATS="sort | uniq -c | sort -n"

function ez_show_pipeables { alias | grep "EZ_" --color; }
