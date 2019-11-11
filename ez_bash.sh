###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${0}" = "-bash" ]] || [[ "${0}" = "-sh" ]]; then
    # To source this script, "${0}" is "-bash" or "-sh"
    [[ -z "${EZ_BASH_HOME}" ]] && echo "\"\${EZ_BASH_HOME}\" is not set!" && return 1
    [[ ! -d "${EZ_BASH_HOME}" ]] && echo "\"${EZ_BASH_HOME}\" is an invalid directory!" && return 1
    if ! source "${EZ_BASH_HOME}/ezb_core/ezb_export_vars.sh"; then
        echo "Cannot source ${EZ_BASH_HOME}/ezb_core/ezb_export_vars.sh" && return 2
    fi
    if ! source "${EZ_BASH_HOME}/ezb_core/ezb_core_utils.sh"; then
        echo "Cannot source ${EZ_BASH_HOME}/ezb_core/ezb_core_utils.sh" && return 2
    fi
    if ! ez_source "${EZ_BASH_HOME}/ezb_core/ezb_func_defs.sh"; then return 2; fi
    if ! ez_source_directory --path "${EZ_BASH_HOME}/ezb_os"; then return 2; fi
    if ! ez_source_directory --path "${EZ_BASH_HOME}/ezb_file"; then return 2; fi
    if ! ez_source_directory --path "${EZ_BASH_HOME}/ezb_time"; then return 2; fi
    # [To Do] List each directory and source them explicitly as the above lines
    for EZ_BASH_LIBRARY_DIR in $(ls -1d ${EZ_BASH_HOME}/ez_bash_*/ |
        grep -v "ezb_core" |
        grep -v "ezb_os" |
        grep -v "ezb_file" |
        grep -v "ezb_time"); do
        # exclude "_test.sh" file
        ez_source_directory --path "${EZ_BASH_LIBRARY_DIR}" --exclude "_test.sh"
     done
else
    # To run this script
    if [[ "$(basename ${0})" = "ez_bash.sh" ]]; then
        if [[ "${1}" = "-i" ]] || [[ "${1}" = "--info" ]]; then echo "EZ-Bash Copyright: Zheng Gao, 2018-05-18"
        elif [[ "${1}" = "-v" ]] || [[ "${1}" = "--version" ]]; then echo "0.0.4"
        elif [[ "${1}" = "-r" ]] || [[ "${1}" = "--requirements" ]]; then echo "Bash 5.*"
        fi
    fi
fi
