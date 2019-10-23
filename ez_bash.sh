###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################

if [[ "${0}" = "-bash" ]] || [[ "${0}" = "-sh" ]]; then
    # To source this script, "${0}" is "-bash" or "-sh"
    if [[ -z "${EZ_BASH_HOME}" ]]; then
        echo "[EZ-BASH] EZ_BASH_HOME is not set!"
        return 1
    else
        if ! source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"; then
            echo "[EZ-BASH][ERROR] Failed to source ${EZ_BASH_HOME}/ez_bash_core/ez_bash_core.sh"
            return 2
        fi
        if ! source "${EZ_BASH_HOME}/ez_bash_core/ez_bash_function.sh"; then
            echo "[EZ-BASH][ERROR] Failed to source ${EZ_BASH_HOME}/ez_bash_core/ez_bash_function.sh"
            return 2
        fi
        for EZ_BASH_LIBRARY_DIR in $(ls -1d ${EZ_BASH_HOME}/ez_bash_*/ | grep -v "ez_bash_core"); do
            # exclude "_test.sh" file
            ez_source_directory --path "${EZ_BASH_LIBRARY_DIR}" --exclude "_test.sh"
        done
    fi
else
    # To run this script
    if [[ "$(basename ${0})" = "ez_bash.sh" ]]; then
        if [[ "${1}" = "-v" ]] || [[ "${1}" = "--version" ]]; then
            echo "EZ-Bash v0.0.3"
        elif [[ "${1}" = "-r" ]] || [[ "${1}" = "--requirements" ]]; then
            echo "Bash 5.*"
        elif [[ "${1}" = "-i" ]] || [[ "${1}" = "--info" ]]; then
            echo "EZ-Bash Copyright: Zheng Gao, 2018-05-18"
        fi
    fi
fi
