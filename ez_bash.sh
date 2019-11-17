###################################################################################################
# ------------------------------------------- EZ-Bash ------------------------------------------- #
###################################################################################################
# Setup Environment Variable "EZ_BASH_HOME"
# > export EZ_BASH_HOME=".../ez_bash"
# To import all ez_bash libraries 
# > source "${EZ_BASH_HOME}/ez_bash.sh"
# To import some ez_bash libraries
# > source "${EZ_BASH_HOME}/ez_bash.sh" "lib_1" "lib_2" ...

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_LOGO="EZ-BASH"
EZB_DIR_WORKSPACE="/var/tmp/ezb_workspace"; mkdir -p "${EZB_DIR_WORKSPACE}"
EZB_DIR_LOGS="${EZB_DIR_WORKSPACE}/logs"; mkdir -p "${EZB_DIR_LOGS}"
EZB_DIR_DATA="${EZB_DIR_WORKSPACE}/data"; mkdir -p "${EZB_DIR_DATA}"
EZB_DEFAULT_LOG="${EZB_DIR_LOGS}/ez_bash.log"

###################################################################################################
# -------------------------------------- Dependency Check --------------------------------------- #
###################################################################################################
function ezb_command_check() {
    if ! which "${1}" &> "${EZB_DIR_LOGS}/${FUNCNAME[0]}_${1}.log"; then return 1; else return 0; fi
}

function ezb_dependency_check() {
    local cmd=""; for cmd in "${@}"; do
        if ! ezb_command_check "${cmd}"; then echo "[${EZB_LOGO}][ERROR] Command \"${cmd}\" not found"; return 1; fi
    done
}

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${0}" = "-bash" ]] || [[ "${0}" = "-sh" ]]; then
    # To source this script, "${0}" is "-bash" or "-sh"
    [[ -z "${EZ_BASH_HOME}" ]] && echo "\"\${EZ_BASH_HOME}\" is not set!" && return 1
    [[ ! -d "${EZ_BASH_HOME}" ]] && echo "\"${EZ_BASH_HOME}\" is an invalid directory!" && return 1
    # Source Core
    if ! source "${EZ_BASH_HOME}/ezb/ezb_core.sh"; then echo "Failed to source \"${EZ_BASH_HOME}/ezb/ezb_core.sh\""; return 2; fi
    # Source Function
    if ! ezb_source "${EZ_BASH_HOME}/ezb/ezb_function.sh"; then return 2; fi
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        # By default source ALL libs
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_os"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_file"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_math"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_set"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_ssh"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_string"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_time"; then return 2; fi
        # External Lib
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_git"; then return 2; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_python"; then return 2; fi
        echo "[${EZB_LOGO}][INFO] Complete loading EZ-Bash libraries!"
    else
        # Source the designated libraries
        for ezb_library_name in "${@}"; do if ! ezb_source_dir --path "${EZ_BASH_HOME}/${ezb_library_name}"; then return 2; fi; done
        unset ezb_library_name
    fi
else
    # To run this script
    if [[ "$(basename ${0})" = "ez_bash.sh" ]]; then
        if [[ "${1}" = "-i" ]] || [[ "${1}" = "--info" ]]; then echo "EZ-Bash Copyright: Zheng Gao, 2018-05-18"
        elif [[ "${1}" = "-v" ]] || [[ "${1}" = "--version" ]]; then echo "0.0.5"
        elif [[ "${1}" = "-r" ]] || [[ "${1}" = "--requirements" ]]; then echo "Bash 5.*"
        fi
    fi
fi
