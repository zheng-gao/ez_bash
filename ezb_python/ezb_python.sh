###################################################################################################
# ------------------------------------------ Variables ------------------------------------------ #
###################################################################################################
EZ_BASH_PYTHON_REQUEST="${EZ_BASH_HOME}/ezb_python/ezb_python_request.py"
EZ_BASH_PYTHON_TABLE="${EZ_BASH_HOME}/ezb_python/ezb_python_table.py"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ezb_python_request() {
    local python_bin="python3"
    if ezb_cmd_check "${python_bin}"; then ${python_bin} "${EZ_BASH_PYTHON_REQUEST}" "${@}"
    else ezb_log_error "Command \"${python_bin}\" not found"; fi
}

function ezb_python_table() {
    local python_bin="python3"
    if ezb_cmd_check "${python_bin}"; then ${python_bin} "${EZ_BASH_PYTHON_TABLE}" "${@}"
    else ezb_log_error "Command \"${python_bin}\" not found"; fi
}