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
EZB_VERSION="2.0.0"
EZB_DEFAULT_BASH_VERSION="5"

###################################################################################################
# ------------------------------------------ Utilities ------------------------------------------ #
###################################################################################################
function ezb_self_version() {
    echo "      Author: Zheng Gao"
    echo "     Version: ${EZB_VERSION}"
    echo "Requirements: Bash v${EZB_DEFAULT_BASH_VERSION}"
}

function ezb_self_tests() {
    local tests_dir="${1}" test_file test_result test_summary has_error test_error
    local spliter="--------------------------------------------------------------------------------"
    for test_file in $(ls -1 ${tests_dir} | grep -v 'utils.sh'); do
        if test_result=$("${tests_dir}/${test_file}"); then
            test_summary+="[✓] ${test_file}\n"
        else
            has_error="True"
            test_summary+="[\e[31m☓\e[0m] ${test_file}\n"
            test_error+="${spliter}\nError in ${test_file}\n${spliter}\n${test_result}"
        fi
    done
    echo -e "${spliter}\n[Test Summary]\n${spliter}\n${test_summary}"
    [[ -n "${has_error}" ]] && echo -e "${test_error}\n"
}

###################################################################################################
# ---------------------------------------- Main Function ---------------------------------------- #
###################################################################################################
if [[ "${0:0:1}" != "-" ]] && [[ "$(basename ${0})" = "ezb.sh" ]]; then
    # To run this script
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo
        echo "[Usage]"
        echo "    -v|--version    Show version info"
        echo "    -t|--tests      Run unit tests"
        echo
        echo "To import EZ-Bash libraries:"
        echo "\$ source ${EZ_BASH_HOME}/ezb.sh --all"
        echo
        exit 0
    fi
    case "${1}" in
        "-v" | "--version") ezb_self_version ;;
        "-t" | "--tests") ezb_self_tests "$(dirname ${0})/tests";;
        *) echo "[EZ-Bash][ERROR] Unknown argument identifier \"${1}\"" && exit 1 ;;
    esac
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
