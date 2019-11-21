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
EZB_VERSION="0.1.1"
EZB_DEFAULT_BASH_VERSION="5"

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${0}" = "-bash" ]] || [[ "${0}" = "-sh" ]]; then
    # To source this script, "${0}" is "-bash" or "-sh"
    bash --version | grep "version ${EZB_DEFAULT_BASH_VERSION}\." &> "/var/tmp/null" || {
        echo "[EZ-Bash][ERROR] \"Bash ${EZB_DEFAULT_BASH_VERSION}\" not found!"; return 1
    }
    # Source EZ-Bash Core, Command & Function
    source "${EZ_BASH_HOME}/ezb/ezb.sh"                      || return 1
    source "${EZ_BASH_HOME}/ezb/ezb_command.sh"              || return 1
    source "${EZ_BASH_HOME}/ezb/ezb_function.sh"             || return 1
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        # By default source ALL other libs
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_file"     || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_math"     || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_set"      || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_ssh"      || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_string"   || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_time"     || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_terminal" || return 1
        ezb_source_dir --path "${EZ_BASH_HOME}/ezb_git"      || return 1
        echo "[EZ-Bash][INFO] Complete loading EZ-Bash libraries!"
    else
        # Source the designated libraries
        for ezb_library_name in "${@}"; do ezb_source_dir --path "${EZ_BASH_HOME}/${ezb_library_name}" || return 1; done
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
                *) echo "[EZ-Bash][ERROR] Unknown argument identifier \"${1}\""; exit 1 ;;
            esac
            [[ -n "${1}" ]] && shift
        done
    fi
fi
