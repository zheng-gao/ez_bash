###################################################################################################
# ------------------------------------------- EZ-Bash ------------------------------------------- #
###################################################################################################
# Setup Environment Variable "EZ_BASH_HOME"
# > export EZ_BASH_HOME=".../ez_bash"
# To import all ez_bash libraries 
# > source "${EZ_BASH_HOME}/ez_bash.sh"
# To import some ez_bash libraries
# > source "${EZ_BASH_HOME}/ez_bash.sh" "lib_1" "lib_2" ...
[[ -z "${EZ_BASH_HOME}" ]] && echo "[ERROR] \"\${EZ_BASH_HOME}\" not set!" && return 1
[[ ! -d "${EZ_BASH_HOME}" ]] && echo "[ERROR] Invalid directory \"${EZ_BASH_HOME}\"" && return 1
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_LOGO="EZ-Bash"
EZB_VERSION="0.1.1"
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
    # Source EZ-Bash Core, Command & Function
    if ! source "${EZ_BASH_HOME}/ezb_core/ezb.sh"; then
        echo "[${EZB_LOGO}][ERROR] Failed to source \"${EZ_BASH_HOME}/ezb_core/ezb.sh\"" && return 1
    fi
    if ! ezb_source "${EZ_BASH_HOME}/ezb_core/ezb_cmd.sh"; then return 1; fi
    if ! ezb_source "${EZ_BASH_HOME}/ezb_core/ezb_function.sh"; then return 1; fi
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
        if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
            echo; echo "[Usage]"
            echo "  -i|--info              Show Copyright"
            echo "  -v|--version           Show Version"
            echo "  -r|--requirements      Show Requirements"; echo
            echo "To import EZ-Bash libraries: \"source ${EZ_BASH_HOME}/ez_bash.sh\""; echo
        fi
        while [[ -n "${1}" ]]; do
            case "${1}" in
                "-i" | "--info") shift; echo "EZ-Bash Copyright: Zheng Gao, 2018-05-18" ;;
                "-v" | "--version") shift; echo "${EZB_VERSION}" ;;
                "-r" | "--requirements") shift; echo "Bash ${EZB_DEFAULT_BASH_VERSION}" ;;
                *) echo "[${EZB_LOGO}][ERROR] Unknown argument identifier \"${1}\""; exit 1 ;;
            esac
            [[ -n "${1}" ]] && shift
        done
    fi
fi
