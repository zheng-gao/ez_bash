#!/usr/bin/env bash

###################################################################################################
# ----------------------------------------- Script Info ----------------------------------------- #
###################################################################################################

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${EZ_BASH_HOME}" == "" ]]; then echo "[EZ-BASH][ERROR] EZ_BASH_HOME is not set!"; exit 1; fi

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ez_source() {
    if [[ "${1}" == "" ]]; then
        echo "[EZ-BASH][ERROR] Empty file path"
        return 1
    fi
    local file_path="${1}"
    if [ ! -f "${file_path}" ]; then
        echo "[EZ-BASH][ERROR] Invalid file path \"${file_path}\""
        return 2
    fi
    if [ ! -r "${file_path}" ]; then
        echo "[EZ-BASH][ERROR] Unreadable file \"${file_path}\""
        return 3
    fi
    if ! source "${file_path}"; then 
        echo "[EZ-BASH][ERROR] Failed to source \"${file_path}\""
        return 4
    fi
    return 0
}

function ez_source_directory() {
    if [[ "${1}" == "" ]]; then
        echo "[EZ-BASH][ERROR] Empty directory path"
        return 1
    fi
    local dir_path="${1}"
    if [ ! -d "${dir_path}" ]; then
        echo "[EZ-BASH][ERROR] Invalid directory path \"${dir_path}\""
        return 2
    fi
    if [ ! -r "${dir_path}" ]; then
        echo "[EZ-BASH][ERROR] Unreadable directory \"${dir_path}\""
        return 3
    fi
    for path in $(find "${dir_path}" -type f -name '*.sh'); do
        if ! source "${path}"; then
            return 4
        fi
    done
    return 0
}