###################################################################################################
# ------------------------------------------- EZ-Bash ------------------------------------------- #
###################################################################################################
# Setup Environment Variable "EZ_BASH_HOME"
# > export EZ_BASH_HOME=".../ez_bash"
# To import all ez_bash libraries 
# > source "${EZ_BASH_HOME}/ezb.sh" --all
# To import some ez_bash libraries
# > source "${EZ_BASH_HOME}/ezb.sh" "lib1" "lib2" ...

###################################################################################################
# -------------------------------------- Global Variables --------------------------------------- #
###################################################################################################
EZB_LOGO="EZ-Bash"
EZB_VERSION="2.0.0"
EZB_DEFAULT_BASH_VERSION="5"

###################################################################################################
# ------------------------------------------ Utilities ------------------------------------------ #
###################################################################################################
function ezb_self_verification {
    if [[ -z "${EZ_BASH_HOME}" ]]; then
        echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] \e[33mEZ_BASH_HOME\e[0m is not set!" && return 1
    elif [[ ! -d "${EZ_BASH_HOME}" ]]; then
        echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] Invalid directory \"${EZ_BASH_HOME}\"" && return 1
    elif [[ ! "$(basename ${EZ_BASH_HOME})" = "ez_bash" ]]; then
        echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] Invalid \e[33mEZ_BASH_HOME\e[0m: ${EZ_BASH_HOME}" && return 1
    fi
}

function ezb_self_installation {
    local ez_bash_home="${1}" uninstall="${2}"
    local bash_profile="${HOME}/.bash_profile" bashrc="${HOME}/.bashrc"
    if [[ -n "${uninstall}" ]]; then
        if [[ -f "${bash_profile}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bash_profile}" > "/dev/null"; then
                grep -v "^export EZ_BASH_HOME=" < "${bash_profile}" > "${bash_profile}.new"
                mv "${bash_profile}.new" "${bash_profile}"
            else
                echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] ${EZB_LOGO} not found!" && return 1
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bashrc}" > "/dev/null"; then
                grep -v "^export EZ_BASH_HOME=" < "${bashrc}" > "${bashrc}.new"
                mv "${bashrc}.new" "${bashrc}"
            else
                echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] ${EZB_LOGO} not found!" && return 1
            fi
        fi
        echo "[${EZB_LOGO}][INFO] Uninstalled ${EZB_LOGO}!"
        echo "[${EZB_LOGO}][INFO] Please restart all the existing terminals."
    else
        if [[ -f "${bash_profile}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bash_profile}" > "/dev/null"; then
                echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] ${EZB_LOGO} was previously installed!" && return 1
            else
                echo -e "export EZ_BASH_HOME=${ez_bash_home}; source ${ez_bash_home}/ezb.sh --all\n" >> "${bash_profile}"
                source "${bash_profile}"
            fi
        elif [[ -f "${bashrc}" ]]; then
            if grep "^export EZ_BASH_HOME=" "${bashrc}" > "/dev/null"; then
                echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] ${EZB_LOGO} was previously installed!" && return 1
            else
                echo -e "export EZ_BASH_HOME=${ez_bash_home}; source ${ez_bash_home}/ezb.sh --all\n" >> "${bashrc}"
                source "${bashrc}"
            fi
        fi
        echo "[${EZB_LOGO}][INFO] Installation Complete!"
        echo "[${EZB_LOGO}][INFO] Please restart all the other terminals."
    fi
}

function ezb_self_version {
    echo
    echo "[${EZB_LOGO}]"
    echo "    Author : Zheng Gao"
    echo "    Version: ${EZB_VERSION}"
    echo "    Require: Bash v${EZB_DEFAULT_BASH_VERSION}"
    echo
}

function ezb_self_unit_test {
    if ! ezb_self_verification; then return 1; fi
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
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    # The script is being executed
    if [[ -z "${1}" ]] || [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
        echo
        echo "[${EZB_LOGO}]"
        echo "    -t|--test         Run unit test"
        echo "    -i|--install      Install ${EZB_LOGO}"
        echo "    -u|--uninstall    Uninstall ${EZB_LOGO}"
        echo "    -v|--version      Show version info"
        echo
        exit 0
    fi
    case "${1}" in
        "-t" | "--test") ezb_self_unit_test "$(dirname ${0})/tests" ;;
        "-i" | "--install") ezb_self_installation "$(pwd)/$(dirname ${0})" ;;
        "-u" | "--uninstall") ezb_self_installation "$(pwd)/$(dirname ${0})" "uninstall" ;;
        "-v" | "--version") ezb_self_version ;;
        *) echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] Unknown argument identifier \"${1}\"" && exit 1 ;;
    esac
else
    # The script is being sourced
    if ! ezb_self_verification; then return 1; fi
    bash --version | grep "version ${EZB_DEFAULT_BASH_VERSION}\." &> "/var/tmp/null" || {
        echo -e "[${EZB_LOGO}][\e[31mERROR\e[0m] \"Bash ${EZB_DEFAULT_BASH_VERSION}\" not found!"; return 1
    }
    rm -f "/var/tmp/null"
    # Source EZ-Bash Core
    source "${EZ_BASH_HOME}/src/core/basic.sh" || return 1
    source "${EZ_BASH_HOME}/src/core/function.sh" || return 1
    # Source Other Libs
    if [[ -z "${1}" ]]; then
        echo "[${EZB_LOGO}][INFO] Imported ${EZB_LOGO} core"
    elif [[ "${1}" = "--all" ]]; then
        # By default source ALL other libs
        ezb_source_dir --path "${EZ_BASH_HOME}/src/libs" || return 1
        echo -e "[${EZB_LOGO}][INFO] Imported $(ezb_string_format 'ForegroundYellow' 'ALL') ${EZB_LOGO} libraries!"
    else
        # Source the designated libraries
        for ezb_library in "${@}"; do
            ezb_source_dir --path "${EZ_BASH_HOME}/src/libs/${ezb_library}" || return 1
        done
        unset ezb_library
        echo "[${EZB_LOGO}][INFO] Imported ${EZB_LOGO} libraries: ${@}"
    fi
fi

unset ezb_self_installation
unset ezb_self_verification
unset ezb_self_unit_test
unset ezb_self_version


