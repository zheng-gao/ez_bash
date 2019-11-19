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
EZB_LOGO="EZ-Bash"
EZB_DIR_WORKSPACE="/var/tmp/ezb_workspace"; mkdir -p "${EZB_DIR_WORKSPACE}"
EZB_DIR_LOGS="${EZB_DIR_WORKSPACE}/logs"; mkdir -p "${EZB_DIR_LOGS}"
EZB_DIR_DATA="${EZB_DIR_WORKSPACE}/data"; mkdir -p "${EZB_DIR_DATA}"

EZB_DEFAULT_BASH_VERSION="5"
EZB_DEFAULT_LOG="${EZB_DIR_LOGS}/ez_bash.log"

###################################################################################################
# -------------------------------------- EZ Bash Functions -------------------------------------- #
###################################################################################################
function ezb_os_name() {
    local name="$(uname -s)"
    if [[ "${name}" = "Darwin" ]]; then echo "macos"
    elif [[ "${name}" = "Linux" ]]; then echo "linux"
    else echo "unknown"; fi
}

function ezb_command_check() {
    if ! which "${1}" &> "${EZB_DEFAULT_LOG}"; then return 1; else return 0; fi
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
    if ! bash --version | grep "version ${EZB_DEFAULT_BASH_VERSION}\." &> "${EZB_DEFAULT_LOG}"; then
        echo "[${EZB_LOGO}][ERROR] \"Bash ${EZB_DEFAULT_BASH_VERSION}\" not found!"; return 1
    fi
    [[ -z "${EZ_BASH_HOME}" ]] && echo "\"\${EZ_BASH_HOME}\" not set!" && return 1
    [[ ! -d "${EZ_BASH_HOME}" ]] && echo "Invalid directory \"${EZ_BASH_HOME}\"" && return 1
    # Source EZ-Bash Core, Command & Function
    if ! source "${EZ_BASH_HOME}/ezb/ezb.sh"; then echo "[${EZB_LOGO}][ERROR] Failed to source \"${EZ_BASH_HOME}/ezb/ezb.sh\""; return 1; fi
    if ! ezb_source "${EZ_BASH_HOME}/ezb/ezb_cmd.sh"; then return 1; fi
    if ! ezb_source "${EZ_BASH_HOME}/ezb/ezb_function.sh"; then return 1; fi
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        # By default source ALL other libs
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_file"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_math"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_set"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_ssh"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_string"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_time"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_terminal"; then return 1; fi
        # External Lib
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_git"; then return 1; fi
        if ! ezb_source_dir --path "${EZ_BASH_HOME}/ezb_python"; then return 1; fi
        echo "[${EZB_LOGO}][INFO] Complete loading EZ-Bash libraries!"
    else
        # Source the designated libraries
        for ezb_library_name in "${@}"; do if ! ezb_source_dir --path "${EZ_BASH_HOME}/${ezb_library_name}"; then return 1; fi; done
        unset ezb_library_name
    fi
else
    # To run this script
    if [[ "$(basename ${0})" = "ez_bash.sh" ]]; then
        if [[ "${1}" = "-i" ]] || [[ "${1}" = "--info" ]]; then echo "EZ-Bash Copyright: Zheng Gao, 2018-05-18"
        elif [[ "${1}" = "-v" ]] || [[ "${1}" = "--version" ]]; then echo "0.1.0"
        elif [[ "${1}" = "-r" ]] || [[ "${1}" = "--requirements" ]]; then echo "Bash 5.*"
        fi
    fi
fi
