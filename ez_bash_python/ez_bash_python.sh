#!/usr/bin/env bash

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

THIS_SCRIPT_NAME="ez_bash_python.sh"
if [[ $0 != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        echo "[EZ-BASH][ERROR] ${THIS_SCRIPT_NAME} is not runnable!"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"
        exit 1
    fi
fi

###################################################################################################
# -------------------------------------- Import Libraries --------------------------------------- #
###################################################################################################
if ! source "${EZ_BASH_HOME}/ez_bash_log/ez_bash_log.sh"; then exit 1; fi
if ! source "${EZ_BASH_HOME}/ez_bash_sanity_check/ez_bash_sanity_check.sh"; then exit 1; fi

###################################################################################################
# ------------------------------------------ Variables ------------------------------------------ #
###################################################################################################
EZ_BASH_PYTHON_REQUESTS="${EZ_BASH_HOME}/ez_bash_python/ez_bash_python_requests.py"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################

function ez_get_python() {
    which python
    # echo python_path
}

function ez_python_request() {
    if ez_command_check --command "python" --silent; then
        local python_bin=$(ez_get_python)
        ez_print_log -l INFO -m "Running Python Command: ${python_bin} ${EZ_BASH_PYTHON_REQUESTS} ${@}"
        ${python_bin} "${EZ_BASH_PYTHON_REQUESTS}" ${@}
    else
        ez_print_log -l ERROR -m "Command \"python\" not found"
    fi
}

