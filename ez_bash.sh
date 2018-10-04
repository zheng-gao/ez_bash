#!/usr/bin/env bash
###################################################################################################
# ---------------------------------------- Release Info  ---------------------------------------- #
###################################################################################################
EZ_BASH_RELEASE_VERSION="0.0.1"
EZ_BASH_REQUIRED_BASH_VERSION="4.4.*"

function ez_bash_print_copy_right() {
    echo "[EZ-BASH] Copyright: Zheng Gao, 2018-05-18" 
}

function ez_bash_print_release_version() {
    echo "[EZ-BASH] Release Version: ${EZ_BASH_RELEASE_VERSION}" 
}

function ez_bash_print_requirements() {
    echo "[EZ-BASH] Require Bash Version: ${EZ_BASH_REQUIRED_BASH_VERSION}"
    echo "[EZ-BASH] Require Evironment Variables: EZ_BASH_HOME"
}

function ez_bash_print_info() {
    ez_bash_print_copy_right
    ez_bash_print_release_version
    ez_bash_print_requirements
}

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

function main() {
    if [[ "${1}" == "-v" ]] || [[ "${1}" == "--version" ]]; then
        ez_bash_print_release_version
    elif [[ "${1}" == "-r" ]] || [[ "${1}" == "--requirements" ]]; then
        ez_bash_print_requirements
    else
        ez_bash_print_info
    fi
}

THIS_SCRIPT_NAME="ez_bash.sh"
if [[ "${0}" != "-bash" ]]; then
    RUNNING_SCRIPT=$(basename "${0}")
    if [[ "${RUNNING_SCRIPT}" == "${THIS_SCRIPT_NAME}" ]]; then
        main "${@}"
    fi
else
    if [[ "${EZ_BASH_HOME}" == "" ]]; then
        # For other script to source
        echo "[EZ-BASH] EZ_BASH_HOME is not set!"
        exit 1
    else
        for EZ_BASH_LIBRARY_DIR in $(ls -1 "${EZ_BASH_HOME}" | grep -v "${THIS_SCRIPT_NAME}"); do
            for EZ_BASH_LIBRARY in $(ls -1 "${EZ_BASH_HOME}/${EZ_BASH_LIBRARY_DIR}" | grep "\.sh"); do
                EZ_BASH_LIBRARY_PATH="${EZ_BASH_HOME}/${EZ_BASH_LIBRARY_DIR}/${EZ_BASH_LIBRARY}"
                if ! source "${EZ_BASH_LIBRARY_PATH}"; then
                    echo "[EZ-BASH] Failed to source ${EZ_BASH_LIBRARY_PATH}"
                fi
            done
        done
    fi
fi
