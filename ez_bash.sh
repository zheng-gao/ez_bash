#!/usr/bin/env bash
###################################################################################################
# ---------------------------------------- Release Info  ---------------------------------------- #
###################################################################################################
EZ_BASH_RELEASE_VERSION="0.0.2"
EZ_BASH_REQUIRED_BASH_VERSION="5.*"

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
    elif [[ "${1}" == "-i" ]] || [[ "${1}" == "--info" ]]; then
        ez_bash_print_info
    fi
}

if [[ "${0}" != "-bash" ]]; then
    if [[ "$(basename ${0})" == "ez_bash.sh" ]]; then
        main "${@}"
    fi
fi

if [[ -z "${EZ_BASH_HOME}" ]]; then
    echo "[EZ-BASH] EZ_BASH_HOME is not set!"
else
    if source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"; then
        for EZ_BASH_LIBRARY_DIR in $(ls -1d ${EZ_BASH_HOME}/*/); do
            # exclude "_test.sh" file
            ez_source_directory --path "${EZ_BASH_LIBRARY_DIR}" --exclude "_test.sh"
        done
    else
        echo "[EZ-BASH][ERROR] Failed to source ${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"
    fi
fi
