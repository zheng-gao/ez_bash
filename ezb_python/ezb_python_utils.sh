###################################################################################################
# ------------------------------------------ Variables ------------------------------------------ #
###################################################################################################
EZ_BASH_PYTHON_REQUEST="${EZ_BASH_HOME}/ez_bash_python/ez_bash_python_request.py"
EZ_BASH_PYTHON_TABLE="${EZ_BASH_HOME}/ez_bash_python/ez_bash_python_table.py"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_python_request() {
    local python_bin="python3"
    if ez_command_check --command "${python_bin}" --silent; then
        ${python_bin} "${EZ_BASH_PYTHON_REQUEST}" "${@}"
    else
        ezb_log_error "Command \"${python_bin}\" not found"
    fi
}

function ez_python_table() {
    local python_bin="python3"
    if ez_command_check --command "${python_bin}" --silent; then
        ${python_bin} "${EZ_BASH_PYTHON_TABLE}" "${@}"
    else
        ezb_log_error "Command \"${python_bin}\" not found"
    fi
}