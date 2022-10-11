###################################################################################################
# ------------------------------------------- EZ-Bash ------------------------------------------- #
###################################################################################################
# Setup Environment Variable "EZ_BASH_HOME"
# > export EZ_BASH_HOME=".../ez_bash"
# To import all ez_bash libraries 
# > source "${EZ_BASH_HOME}/ezb.sh" --all
# To import some ez_bash libraries
# > source "${EZ_BASH_HOME}/ezb.sh" "lib1" "lib2" ...
[[ -z "${EZ_BASH_HOME}" ]] && echo "[ERROR] \"\${EZ_BASH_HOME}\" not set!" && return 1
[[ ! -d "${EZ_BASH_HOME}" ]] && echo "[ERROR] Invalid directory \"${EZ_BASH_HOME}\"" && return 1
###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_LOGO="EZ-Bash"
EZB_VERSION="0.1.3"
EZB_DEFAULT_BASH_VERSION="5"

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${0:0:1}" != "-" ]] && [[ "$(basename ${0})" = "ezb.sh" ]]; then
    # To run this script
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo; echo "[Usage]"
        echo "  -i|--info              Show Copyright"
        echo "  -v|--version           Show Version"
        echo "  -r|--requirements      Show Requirements"; echo
        echo "To import EZ-Bash libraries: \"source ${EZ_BASH_HOME}/ezb.sh\""; echo
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
else
    # To source this script, "${0}" is "-bash" or "-sh"
    bash --version | grep "version ${EZB_DEFAULT_BASH_VERSION}\." &> "/var/tmp/null" || {
        echo "[EZ-Bash][ERROR] \"Bash ${EZB_DEFAULT_BASH_VERSION}\" not found!"; return 1
    }
    rm -f "/var/tmp/null"
    # Source EZ-Bash Core
    source "${EZ_BASH_HOME}/core/basic.sh" || return 1
    source "${EZ_BASH_HOME}/core/function.sh" || return 1
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        echo "[EZ-Bash][INFO] Complete loading EZ-Bash core"
    elif [[ "${1}" = "--all" ]]; then
        # By default source ALL other libs
        ezb_source_dir --path "${EZ_BASH_HOME}/libs" || return 1
        echo -e "[EZ-Bash][INFO] Complete loading $(ezb_string_format ForegroundYellow ALL) EZ-Bash libraries!"
    else
        # Source the designated libraries
        for ezb_library in "${@}"; do
            ezb_source_dir --path "${EZ_BASH_HOME}/libs/${ezb_library}" || return 1
        done
        unset ezb_library
        echo "[EZ-Bash][INFO] Complete loading EZ-Bash libraries: ${@}"
    fi
fi
